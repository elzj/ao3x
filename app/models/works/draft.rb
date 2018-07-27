class Draft < ApplicationRecord
  belongs_to :user
  serialize :metadata, JSON

  WORK_ATTRIBUTES = %w(
    type
    title
    summary
    notes
    endnotes
    expected_number_of_chapters
    backdate
    restricted
    anon_commenting_disabled
    moderated_commenting_enabled
  ).freeze

  TAG_FIELDS = %w(
    ratings
    warnings
    categories
    fandoms
    characters
    relationships
    freeforms
  ).freeze

  FIELDS = WORK_ATTRIBUTES + TAG_FIELDS + %w(content)

  # Define getter and setter methods for each field that
  # read from and write to the metadata hash
  FIELDS.each do |field|
    define_method field do
      if instance_variable_get("@#{field}").nil?
        instance_variable_set("@#{field}", metadata[field])
      end
      instance_variable_get("@#{field}")
    end

    define_method "#{field}=" do |value|
      instance_variable_set("@#{field}", value)
      metadata[field] = value
    end
  end
  
  def self.latest(user_id)
    where(user_id: user_id).order('updated_at DESC').first
  end

  ### INSTANCE METHODS ###

  def metadata
    @metadata ||= {}
  end

  def work_data
    metadata.slice(*WORK_ATTRIBUTES)
  end

  def chapter_data
    { 'content' => metadata['content'] }
  end

  def tag_data
    TAG_FIELDS.inject({}) do |tags, field|
      tags[field.classify] = metadata[field]
      tags
    end
  end

  def creators
    user ? [user.default_pseud_id].compact : []
  end
end
