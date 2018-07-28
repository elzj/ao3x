class Tag < ApplicationRecord
  TAGGABLE_TYPES = %w(Rating Warning Category Character Relationship Freeform).freeze

  ### ASSOCIATIONS
  has_many :taggings, foreign_key: :tagger_id

  ### VALIDATIONS
  validates :name,
    presence: true,
    uniqueness: true,
    length: {
      minimum: ArchiveConfig.tags[:name_min],
      maximum: ArchiveConfig.tags[:name_max]
    }

  ### CALLBACKS

  ### CLASS METHODS

  # Given a type and a comma-separated list of tag names, find or create them
  # It's important to return the list in the original order
  def self.process_list(tag_type, tag_string)
    names = tag_string.split(',').map(&:strip).uniq.select{ |name| name.present? }
    tags = Tag.where(name: names).group_by(&:name)
    new_tags = names - tags.keys
    new_tags.each do |name|
      tags[name] = Tag.create(type: tag_type, name: name)
    end
    names.map{ |name| tags[name] }.flatten
  end

  def self.all_for_works(work_ids)
    Tagging.joins(:tag).
            where(
              taggable_type: 'Work',
              taggable_id: work_ids
            ).select(
              "tags.id AS id, tags.name AS name, tags.type AS type, taggable_id AS work_id"
            ).group_by(&:work_id)
  end

  ## INSTANCE METHODS

  def to_param
    "#{id}-#{name[0..20].parameterize}"
  end
end
