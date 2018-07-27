class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         # :confirmable,
         :registerable,
         :recoverable,
         :rememberable,
         :lockable,
         :trackable,
         :validatable

  # Must come after Devise modules in order to alias devise_valid_password?
  # properly
  include LegacyAuthentication

  ### ASSOCIATIONS
  has_many :pseuds
  has_one :profile
  has_one :preference

  ### VALIDATIONS
  validates :login,
    presence: true,
    length: {
      within: ArchiveConfig.users[:login_min]..ArchiveConfig.users[:login_max]
    },
    format: {
      with: /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/,
      message: "must begin and end with a letter or number; it may also contain underscores but no other characters."
    },
    uniqueness: {
      case_sensitive: false,
      message: "has already been taken"
    }
  validates :password,
    length: {
      within: ArchiveConfig.users[:password_min]..ArchiveConfig.users[:password_max]
    }
  validates_confirmation_of :password
  validates :email, email: true

  ### CALLBACKS

  ### CLASS METHODS

  ## INSTANCE METHODS

  def default_pseud
    pseuds.default.first || Pseud.create_default(self)
  end

  def default_pseud_id
    default_pseud.pluck(:id)
  end

  def current_profile
    profile || Profile.create_default(self)
  end

  def current_preferences
    preference || Preference.create_default(self)
  end
end
