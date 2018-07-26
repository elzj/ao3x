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

  ### VALIDATIONS
  validates_confirmation_of :password
  validates :login, presence: true
  validates_length_of :login,
                      within: ArchiveConfig.users[:login_min]..ArchiveConfig.users[:login_max]
  validates_length_of :password,
                      within: ArchiveConfig.users[:password_min]..ArchiveConfig.users[:password_max]
  validates_format_of :login,
                      message: "must begin and end with a letter or number; it may also contain underscores but no other characters.",
                      with: /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/
  validates_uniqueness_of :login, case_sensitive: false, message: "has already been taken"
  validates :email, email: true

  ### CALLBACKS

  ### CLASS METHODS

  ## INSTANCE METHODS
end
