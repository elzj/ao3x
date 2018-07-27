module Chaptery
  def self.included(chapter)
    chapter.class_eval do
      has_many :creatorships, as: :creation
      has_many :pseuds, through: :creatorships
      belongs_to :work
      # acts_as_commentable
      # has_many :kudos, as: :commentable

      validates :title,
        length: {
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
      validates :content,
        length: {
          maximum: ArchiveConfig.chapters[:content_max]
        }

      scope :in_order, -> { order(:position) }
      scope :posted, -> { where(posted: true) }

      before_validation :clean_title
    end
    chapter.extend(ClassMethods)
  end

  module ClassMethods
  end

  def clean_title
    self.title = title.strip if title
  end
end