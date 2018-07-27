class UserRegistration
  attr_reader :user
  
  def initialize(user_data)
    @user = User.new(user_data)
    @errors = []
  end

  def save
    User.transaction do
      user.save
      Pseud.create_default(user)
      Profile.create_default(user)
      Preference.create_default(user)
    end
  end
end
