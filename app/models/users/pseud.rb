class Pseud < ApplicationRecord
  ### ASSOCIATIONS
  belongs_to :user
  has_many :creatorships

  ### VALIDATIONS
  validates :name,
    presence: true,
    length: {
      within: ArchiveConfig.pseuds[:name_min]..ArchiveConfig.pseuds[:name_max]
    },
    format: {
      with: /\A[\p{Word} -]+\Z/u,
      message: 'can contain letters, numbers, spaces, underscores, and dashes.'
    },
    uniqueness: {
      scope: :user_id, case_sensitive: false
    }
  # Extra format validation because you can't combine them
  validates :name,
    format: {
      with: /\p{Alnum}/u,
      message: 'must contain at least one letter or number.'
    }
  validates :description,
    length: {
      maximum: ArchiveConfig.pseuds[:description_max],
      allow_blank: true
    }

  ### CALLBACKS

  ### CLASS METHODS

  scope :default, -> { where(is_default: true) }

  def self.create_default(user)
    Pseud.create(user_id: user.id, name: user.login, is_default: true)
  end

  # Given a list of work ids, return a hash of pseuds keyed by the work ids
  # Returns name, user_name, and work_id for each pseud
  def self.all_for_works(work_ids)
    pseud_select = "name, creatorships.creation_id AS work_id, users.login AS user_name"
    conditions = {
      creatorships: {
        creation_type: 'Work',
        creation_id: work_ids
      }
    }
    Pseud.joins(:creatorships).
          joins(:user).
          select(pseud_select).
          where(conditions).
          group_by(&:work_id)
  end

  ## INSTANCE METHODS

  def byline
    login = self.respond_to?(:user_name) ? user_name : user.login
    name == login ? name : "#{name} (#{login})"
  end
end
