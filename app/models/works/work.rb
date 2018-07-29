class Work < ApplicationRecord

  TYPES = [
    ['Text or Multimedia', 'TextWork'],
    ['Art', 'ArtWork'],
    ['Audio', 'AudioWork'],
    ['Video', 'VideoWork']
  ]

  ### ASSOCIATIONS
  has_many :chapters
  has_many :creatorships, as: :creation
  has_many :pseuds, through: :creatorships
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings

  ### VALIDATIONS
  validates :title,
    presence: true,
    length: {
      minimum: ArchiveConfig.works[:title_min],
      maximum: ArchiveConfig.works[:title_max]
    }

  validates :summary,
    length: {
      maximum: ArchiveConfig.works[:summary_max]
    }

  validates :notes,
    length: {
      maximum: ArchiveConfig.works[:notes_max]
    }

  validates :endnotes,
    length: {
      maximum: ArchiveConfig.works[:notes_max]
    }

  validates :type,
    inclusion: {
      in: TYPES.map(&:last)
    }

  ### CALLBACKS
  before_validation :clean_title

  def clean_title
    self.title = title.strip if title
  end

  ### CLASS METHODS

  ## INSTANCE METHODS

    # 1/1, 2/3, 5/?, etc.
  def chapter_total_display
    current = posted? ? chapters.posted.count.to_s : '1'
    current + '/' + expected_length_display
  end

  def expected_length_display
    expected_number_of_chapters.to_s || '?'
  end
end
