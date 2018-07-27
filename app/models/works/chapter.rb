class Chapter < ApplicationRecord
  include Chaptery
  ### ASSOCIATIONS

  ### VALIDATIONS
  validates :content,
    presence: true,
    length: {
      minimum: ArchiveConfig.chapters[:content_min]
    }

  ### CALLBACKS

  ### CLASS METHODS

  ## INSTANCE METHODS
end
