class Profile < ApplicationRecord
  ### ASSOCIATIONS

  belongs_to :user
  
  ### VALIDATIONS

  ### CALLBACKS

  ### CLASS METHODS

  def self.create_default(user)
    create(user_id: user.id)
  end

  ## INSTANCE METHODS
end
