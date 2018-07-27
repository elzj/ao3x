class Language < ApplicationRecord
  ### ASSOCIATIONS

  has_many :works
  
  ### VALIDATIONS

  validates_presence_of :short
  validates_uniqueness_of :short
  validates_presence_of :name

  ### CALLBACKS

  after_commit :expire_cache

  ### CLASS METHODS

  def self.for_posting
    Rails.cache.fetch("posting_languages") {
      all.pluck(:name, :id)
    }
  end

  ## INSTANCE METHODS

  def to_param
    short
  end

  def expire_cache
    Rails.cache.delete("posting_languages")
  end
end
