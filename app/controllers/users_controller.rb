class UsersController < ApplicationController
  before_action :user_params, only: [:create]

  def new
    # Display the registration form
  end

  def create
    if User.exists?(email: user_params[:email])
      render json: { error: 'User already exists with this email' }, status: :unprocessable_entity
    else
      user = User.new(user_params)
      if user.save
        # Send confirmation email logic goes here
        render json: { message: 'User created successfully. Please check your email to confirm.' }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def email_valid?(email)
    email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  end

  def password_match?
    user_params[:password] == user_params[:password_confirmation]
  end
end
