class Tag < ApplicationRecord
  TAGGABLE_TYPES = %w(Rating Warning Category Character Relationship Freeform).freeze

  ### ASSOCIATIONS
  has_many :taggings, foreign_key: :tagger_id

  ### VALIDATIONS

  ### CALLBACKS

  ### CLASS METHODS

  # Given a type and a comma-separated list of tag names, find or create them
  # It's important to return the list in the original order
  def self.process_list(tag_type, tag_string)
    names = tag_string.split(',').map(&:strip).select{ |name| name.present? }
    tags = Tag.where(name: names).group_by(&:name)
    new_tags = names - tags.keys
    new_tags.each do |name|
      tags[name] = Tag.create(type: tag_type, name: name)
    end
    names.map{ |name| tags[name] }.flatten
  end

  ## INSTANCE METHODS
end
