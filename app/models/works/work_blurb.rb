class WorkBlurb < SimpleDelegator
  delegate :url_helpers, to: 'Rails.application.routes'
  
  # Just a fancy way of returning search results
  # while preserving their original order
  def self.from_search(search_results)
    work_ids = search_results.map{ |hit| hit['_id'] }
    works = Work.where(id: work_ids).group_by(&:id)
    works_in_order = search_results.map{ |hit|
      work = works[hit['_id'].to_i]&.first
      ghostbust(hit['_id']) if work.nil?
      work
    }.compact
    from_works(works_in_order)
  end

  # Send missing records off to be cleaned up
  def self.ghostbust(id)
    GhostbusterJob.perform_later({ type: 'Work', id: id })
  end

  # Wrap an array of works in blurb objects
  def self.from_works(works)
    work_ids = works.pluck(:id)
    pseuds = all_pseuds(work_ids)
    tags = all_tags(work_ids)
    works.map do |work|
      WorkBlurb.new(work).tap { |blurb|
        blurb.tags = tags[work.id] || []
        blurb.pseuds = pseuds[work.id] || []
      }
    end
  end

  def self.all_tags(work_ids)
    Tag.all_for_works(work_ids)
  end

  def self.all_pseuds(work_ids)
    Pseud.all_for_works(work_ids)
  end

  attr_accessor :tags, :pseuds

  def creator_links
    pseuds.map{ |p| creator_link(p) }
  end

  def creator_link(pseud)
    url = url_helpers.user_pseud_works_url(
      user_id: pseud.user_name,
      pseud_id: pseud.name,
      id: pseud.name,
      host: ArchiveConfig.host
    )
    { name: pseud.byline, url: url }
  end

  def tag_data
    return {} unless tags.present?
    tags.inject({}) do |data, tag|
      data[tag.type] ||= []
      data[tag.type] << tag_link(tag)
      data
    end
  end

  def tag_links
    types = Tag::TAGGABLE_TYPES - ['Fandom']
    types.map { |type| tag_data[type] }.flatten.compact
  end

  def tag_link(tag)
    url = url_helpers.tag_works_url(
      tag_id: tag.to_param,
      host: ArchiveConfig.host
    )
    { name: tag.name, url: url }
  end

  def fandom_links
    tag_data['Fandom'] || []
  end

  def as_json(options=nil)
    __getobj__.as_json(
      only: WorkIndexer::WHITELISTED_FIELDS
    ).merge(
      tags: tag_data,
      creators: creator_links
    )
  end
end
