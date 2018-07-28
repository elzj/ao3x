class WorkSearch < Search
  include TaggableSearch

  def self.main_indexer
    WorkIndexer
  end

  def search_results
    response = search
    hits = response.dig('hits', 'hits') || []
    page_count = (response.dig('hits', 'total') / per_page.to_f).ceil
    {
      works: WorkBlurb.from_search(hits),
      page_count: page_count
    }
  end

  # Combine the available filters
  def filters
    add_owner
    set_language

    @filters ||= (
      visibility_filters +
      work_filters +
      creator_filters +
      collection_filters +
      tag_filters +
      range_filters
    ).flatten.compact
  end

  def exclusion_filters
    @exclusion_filters ||= [
      tag_exclusion_filter,
      named_tag_exclusion_filter
    ].flatten.compact
  end

  # Combine the available queries
  # In this case, name is the only text field
  def queries
    @queries = [general_query] unless general_query.blank? #if options[:q] || options[:query].present?
  end

  def add_owner
    owner = options[:works_parent]
    field = case owner
            when Tag
              :filter_ids
            when Pseud
              :pseud_ids
            when User
              :user_ids
            when Collection
              :collection_ids
            end
    return unless field.present?
    options[field] ||= []
    options[field] << owner.id
  end

  def set_language
    lang = options[:language_id]
    return if lang.blank? || lang.to_i > 0
    options[:language_id] = Language.where(short: lang).pluck(:id).first
  end

  ####################
  # GROUPS OF FILTERS
  ####################

  def visibility_filters
    [
      term_filter(:posted, 'true'),
      term_filter(:hidden_by_admin, 'false'),
      (term_filter(:restricted, 'false') unless include_restricted?),
      (term_filter(:in_unrevealed_collection, 'false') unless include_unrevealed?),
      (term_filter(:in_anon_collection, 'false') unless include_anon?)
    ]
  end

  def work_filters
    [
      (term_filter(:complete, b(options[:complete]))    if options[:complete].present?),
      (term_filter(:expected_number_of_chapters, 1)     if options[:single_chapter].present?),
      (term_filter(:language_id, options[:language_id]) if options[:language_id].present?),
      (term_filter(:crossover, b(options[:crossover]))  if options[:crossover].present?),
      (terms_filter(:work_type, options[:work_types])   if options[:work_types]),
    ]
  end

  def creator_filters
    [
      (terms_filter(:user_ids, user_ids) if user_ids.present?),
      (terms_filter(:pseud_ids, pseud_ids) if pseud_ids.present?)
    ]
  end

  def collection_filters
    [
      (terms_filter(:collection_ids, options[:collection_ids]) if options[:collection_ids].present?)
    ]
  end

  def tag_filters
    [
      filter_id_filter,
      named_tag_inclusion_filter
    ].flatten.compact
  end

  def range_filters
    ranges = []
    [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at].each do |countable|
      if options[countable].present?
        ranges << { range: { countable => SearchRange.parsed(options[countable]) } }
      end
    end
    ranges += [date_range_filter, word_count_filter].compact
    ranges
  end

  ####################
  # FILTERS
  ####################

  def filter_id_filter
    if filter_ids.present?
      filter_ids.map { |filter_id| term_filter(:filter_ids, filter_id) }
    end
  end

  # This filter is used to restrict our results to only include works
  # whose "tag" text matches all of the tag names in included_tag_names. This
  # is useful when the user enters a non-existent tag, which would be discarded
  # by the TaggableQuery.filter_ids function.
  def named_tag_inclusion_filter
    return if included_tag_names.blank?
    match_filter(:tag, included_tag_names.join(" "))
  end

  def tag_exclusion_filter
    if exclusion_ids.present?
      exclusion_ids.map { |exclusion_id| term_filter(:filter_ids, exclusion_id) }
    end
  end

  # This set of filters is used to prevent us from matching any works whose
  # "tag" text matches one of the passed-in tag names. This is useful when the
  # user enters a non-existent tag, which would be discarded by the
  # TaggableQuery.exclusion_ids function.
  #
  # Unlike the inclusion filter, we must separate these into different match
  # filters to get the results that we want (that is, excluding "A B" and "C D"
  # is the same as "not(A and B) and not(C and D)").
  def named_tag_exclusion_filter
    excluded_tag_names.map do |tag_name|
      match_filter(:tag, tag_name)
    end
  end

  def date_range_filter
    date_from = processed_date options[:date_from]
    date_to =   processed_date options[:date_to]
    range_if_present(:revised_at, date_from, date_to)
  end

  def word_count_filter
    numberfy   = ->(str) { str && str.delete(",._").to_i }
    words_from = numberfy.call(options[:words_from])
    words_to   = numberfy.call(options[:words_to])
    range_if_present(:word_count, words_from, words_to)
  end

  ####################
  # QUERIES
  ####################

  # Search for a tag by name
  # Note that fields don't need to be explicitly included in the
  # field list to be searchable directly (ie, "complete:true" will still work)
  def general_query
    input = (options[:q] || options[:query] || "").dup
    query = generate_search_text(input)

    return {
      query_string: {
        query: query,
        fields: ["creators^5", "title^7", "endnotes", "notes", "summary", "tag"],
        default_operator: "AND"
      }
    } unless query.blank?
  end

  def generate_search_text(query = '')
    search_text = query
    [:title, :creators].each do |field|
      search_text << split_query_text_words(field, options[field])
    end
    if options[:collection_ids].blank? && collected?
      search_text << " collection_ids:*"
    end
    escape_slashes(search_text.strip)
  end

  def sort
    column = options[:sort_column].present? ? options[:sort_column] : default_sort
    direction = options[:sort_direction].present? ? options[:sort_direction] : 'desc'
    sort_hash = { column => { order: direction } }

    if column == 'revised_at'
      sort_hash[column][:unmapped_type] = 'date'
    end

    sort_hash
  end

  # When searching outside of filters, use relevance instead of date
  def default_sort
    facet_tags? ? 'revised_at' : '_score'
  end

  def aggregations
    aggs = {}
    if collected?
      aggs[:collections] = { terms: { field: 'collection_ids' } }
    end

    if facet_tags?
      Tag::TAGGABLE_TYPES.each do |facet_type|
        facet_type = facet_type.downcase
        aggs[facet_type] = { terms: { field: "#{facet_type}_ids" } }
      end
    end

    { aggs: aggs }
  end

  ####################
  # HELPERS
  ####################

  def facet_tags?
    options[:faceted]
  end

  def collected?
    options[:collected]
  end

  def include_restricted?
    true
#    User.current_user.present? || options[:show_restricted]
  end

  # Include unrevealed works only if we're on a collection page
  # OR the collected works page of a user
  def include_unrevealed?
    options[:collection_ids].present? || collected?
  end

  # Include anonymous works if we're not on a user/pseud page
  # OR if the user is viewing their own collected works
  def include_anon?
    (user_ids.blank? && pseud_ids.blank?) ||
      (collected? && options[:works_parent].present? && options[:works_parent] == User.current_user)
  end

  def user_ids
    options[:user_ids]
  end

  def pseud_ids
    options[:pseud_ids]
  end
end
