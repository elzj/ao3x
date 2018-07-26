# Create a sitewide config from yml files
require 'ostruct'
require 'yaml'
hash = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
if File.exist?("#{Rails.root}/config/local.yml")
  hash.merge! YAML.load_file("#{Rails.root}/config/local.yml")[Rails.env]
end
::ArchiveConfig = OpenStruct.new(hash.with_indifferent_access).freeze
