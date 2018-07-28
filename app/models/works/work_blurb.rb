class WorkBlurb < SimpleDelegator
  FIELDS_FROM_SEARCH = %i(id title summary notes endnotes word_count complete filter_ids revised_at creators)

  FIELDS_FROM_SEARCH.each do |field|
    define_method(field) { data[field] || super() }
  end

  def self.from_search(search_results)
    work_ids = search_results.map{ |hit| hit['_id'] }
    works    = Work.where(id: work_ids).
                    inject({}) { |data, work| data[work.id] = work; data }
    all_tags = Tag.all_for_works(works)

    search_results.map do |hit|
      source = hit['_source']
      work   = works[hit['_id'].to_i]
      tags   = all_tags[work.id]
      WorkBlurb.new_with_data(work, source.merge(preloaded_tags: tags))
    end
  end

  def self.new_with_data(work, data={})
    new(work).tap {|work| work.data = data.with_indifferent_access }
  end

  attr_accessor :data

  def tag_data
    if data[:preloaded_tags]
      data[:preloaded_tags].group_by(&:type)
    else
      @tags ||= Tag.where(id: filter_ids).select(:id, :name, :type).group_by(&:type)
    end
  end

  def tag_links
    types = Tag::TAGGABLE_TYPES - ['Fandom']
    tag_list = types.map{|type| tag_data[type] }.flatten.compact
    tag_list.map{ |tag| tag_link(tag) }.join(', ')
  end

  def tag_link(tag)
    param = tag.name.gsub('/', '*s*').gsub('&', '*a*').gsub('.', '*d*').gsub('?', '*q*').gsub('#', '*h*')
    "<a href='/tags/#{param}/works'>#{tag.name}</a>"
  end

  def fandom_links
    tag_data['Fandom'] ||= []
    tag_data['Fandom'].compact.
                       map{ |tag| tag_link(tag) }.
                       join(', ')
  end

  def as_json(options=nil)
    data.slice(*FIELDS_FROM_SEARCH).merge(tags: tag_data)
  end
end
