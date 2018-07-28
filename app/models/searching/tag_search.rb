class TagSearch < Search
  def self.main_indexer
    TagIndexer
  end

  def search_results
    response = search
    response.dig('hits', 'hits')&.map{ |hit| hit['_source'] }
    # QueryResult.new(klass, response, { page: page, per_page: per_page })
  end

  def filters
    [
      type_filter,
      canonical_filter,
      unwrangleable_filter,
      media_filter,
      fandom_filter,
      character_filter,
      suggested_fandom_filter,
      suggested_character_filter
    ].compact
  end

  def queries
    [name_query].compact
  end

  # Tags have a different default per_page value:
  def per_page
    options[:per_page] || 50
  end

  def sort
    direction = options[:sort_direction]&.downcase
    case options[:sort_column]
    when "taggings_count_cache"
      column = "uses"
      direction ||= "desc"
    when "created_at"
      column = "created_at"
      direction ||= "desc"
    else
      column = "sortable_name"
      direction ||= "asc"
    end
    sort_hash = { column => { order: direction } }

    if column == 'created_at'
      sort_hash[column][:unmapped_type] = 'date'
    end

    sort_hash
  end

  ################
  # FILTERS
  ################

  def type_filter
    { term: { tag_type: options[:type] } } if options[:type]
  end

  def canonical_filter
    term_filter(:canonical, bool_value(options[:canonical])) if options[:canonical].present?
  end

  def unwrangleable_filter
    term_filter(:unwrangleable, bool_value(options[:unwrangleable])) if options[:unwrangleable].present?
  end

  def media_filter
    terms_filter(:media_ids, options[:media_ids]) if options[:media_ids]
  end

  def fandom_filter
    terms_filter(:fandom_ids, options[:fandom_ids]) if options[:fandom_ids]
  end

  def character_filter
    terms_filter(:character_ids, options[:character_ids]) if options[:character_ids]
  end

  def suggested_fandom_filter
    terms_filter(:pre_fandom_ids, options[:pre_fandom_ids]) if options[:pre_fandom_ids]
  end

  def suggested_character_filter
    terms_filter(:pre_character_ids, options[:pre_character_ids]) if options[:pre_character_ids]
  end

  ################
  # QUERIES
  ################

  def name_query
    return unless options[:name]
    {
      query_string: {
        query: escape_reserved_characters(options[:name]),
        fields: ["name.exact^2", "name"],
        default_operator: "and"
      }
    }
  end
end