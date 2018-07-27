class Video < ApplicationRecord
  ### ASSOCIATIONS
  belongs_to :work

  include VideoUploader::Attachment.new(:video)

  ### VALIDATIONS

  ### CALLBACKS

  ### CLASS METHODS

  ## INSTANCE METHODS
end
