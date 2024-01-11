class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def edit_user_profile(id, name, email, password, password_confirmation)
    user = User.find_by(id: id)
    return { error: 'User not found' } unless user

    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    if email.present? && (email == user.email || !(email =~ email_regex))
      return { error: 'Invalid or unchanged email' }
    end

    if User.exists?(email: email)
      return { error: 'Email already taken' }
    end

    if password.present?
      if password == password_confirmation
        user.password_digest = User.digest(password)
      else
        return { error: 'Password confirmation does not match' }
      end
    end

    user.name = name
    user.email = email

    if user.save
      # Assuming UserMailer and confirmation token logic is already implemented
      UserMailer.email_confirmation(user).deliver_now if email.present?
      { user: user, message: 'User profile updated successfully' }
    else
      { error: user.errors.full_messages }
    end
  end
end
