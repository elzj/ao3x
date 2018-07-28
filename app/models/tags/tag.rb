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
    tag_select = "tags.id, name, type, taggings.taggable_id AS work_id"
    conditions = {
      taggings: {
        taggable_type: 'Work',
        taggable_id: work_ids
      }
    }
    Tag.joins(:taggings).
        where(conditions).
        select(tag_select).
        group_by(&:work_id)
  end

  ## INSTANCE METHODS

  def to_param
    "#{id}-#{name[0..20].parameterize}"
  end
end
