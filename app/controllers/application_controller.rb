class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # POST /register
  def register_user
    # Validate input parameters
    return unless params[:name].present? && params[:email].present? &&
                  params[:password].present? && params[:password_confirmation].present?

    # Check email format and uniqueness
    return unless params[:email] =~ URI::MailTo::EMAIL_REGEXP &&
                  User.find_by(email: params[:email]).nil?

    # Check password confirmation
    return unless params[:password] == params[:password_confirmation]

    # Create user record
    user = User.new(user_params)
    user.email_confirmation_token = SecureRandom.urlsafe_base64
    user.status = 'pending_email_confirmation'

    if user.save
      # Send confirmation email
      UserMailer.with(user: user).confirmation_email.deliver_later

      # Return appropriate user information
      render json: user.as_json(except: [:password_digest]), status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def edit_user_profile
    user = User.find_by(id: params[:id])
    return render json: { error: 'User not found' }, status: :not_found unless user

    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    if params[:email].present? && (params[:email] == user.email || !(params[:email] =~ email_regex))
      return render json: { error: 'Invalid or unchanged email' }, status: :unprocessable_entity
    end

    if User.exists?(email: params[:email])
      return render json: { error: 'Email already taken' }, status: :unprocessable_entity
    end

    if params[:password].present?
      if params[:password] == params[:password_confirmation]
        user.password_digest = User.digest(params[:password])
      else
        return render json: { error: 'Password confirmation does not match' }, status: :unprocessable_entity
      end
    end

    user.assign_attributes(user_params)

    if user.save
      # Assuming UserMailer and confirmation token logic is already implemented
      UserMailer.email_confirmation(user).deliver_now if params[:email].present?
      render json: { user: user.as_json(except: [:password_digest]), message: 'User profile updated successfully' }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
