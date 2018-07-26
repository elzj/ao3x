class Pseud < ApplicationRecord
  ### ASSOCIATIONS
  belongs_to :user
  has_many :creatorships

  ### VALIDATIONS

  ### CALLBACKS

  ### CLASS METHODS

  ## INSTANCE METHODS
end
