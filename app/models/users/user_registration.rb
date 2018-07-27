class UserRegistration
  attr_reader :user
  
  def initialize(user)
    @user = user
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
