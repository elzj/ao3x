class TagIndexer < Indexer

  WHITELISTED_FIELDS = %i(
    id name merger_id canonical created_at sortable_name
  ).freeze

  def self.klass
    "Tag"
  end

  def self.settings
    {
      analysis: {
        analyzer: {
          tag_name_analyzer: {
            type: "custom",
            tokenizer: "standard",
            filter: [
              "lowercase"
            ]
          },
          exact_tag_analyzer: {
            type: "custom",
            tokenizer: "keyword",
            filter: [
              "lowercase"
            ]
          }
        }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: WHITELISTED_FIELDS
    ).merge(
      tag_type: object.type,
      uses: object.taggings_count_cache,
      suggest: suggester(object)
    ).merge(parent_data(object))
  end

  # Index parent data for tag wrangling searches
  def parent_data(tag)
    data = {}
    # parents = tag.parents.select(:id, :type).group_by(&:type)
    # data[:parent_ids] = parents.values.flatten.map{ |t| t.id.to_s }
    # %w(Media Fandom Character).each do |parent_type|
    #   next unless tag.parent_types.include?(parent_type)
    #   key = "#{parent_type.downcase}_ids"
    #   ids = parents[parent_type] ? parents[parent_type].map(&:id) : [0]
    #   data[key] = ids
    #   next if parent_type == "Media"
    #   data["pre_#{key}"] = tag.suggested_parent_ids(parent_type)
    # end
    data
  end

  def suggester(tag)
    {
      input: tag.suggester_tokens,
      weight: tag.suggester_weight,
      contexts: {
        typeContext: [
          tag.type,
          tag.canonical? ? "Canonical#{tag.type}" : nil
        ].compact
      }
    }
  end
end
