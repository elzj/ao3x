require 'mail'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      email = Mail::Address.new(value)
      validity = email.domain && email.domain.match('\.') && email.address == value
    rescue
      validity = false
    end
    record.errors[attribute] << (options[:message] || "is invalid") unless validity
  end
end
