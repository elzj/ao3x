class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :confirmable,
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

  ### CALLBACKS

  ### CLASS METHODS

  ## INSTANCE METHODS
end
