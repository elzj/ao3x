class Preference < ApplicationRecord
  ### ASSOCIATIONS
  
  belongs_to :user

  ### VALIDATIONS

  ### CALLBACKS

  ### CLASS METHODS

  def self.create_default(user)
    create(
      user_id: user.id,
      preferred_locale: ArchiveConfig.locales[:default_id]
    )
  end

  ## INSTANCE METHODS  
end
