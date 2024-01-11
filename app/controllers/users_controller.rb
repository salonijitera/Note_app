class UsersController < ApplicationController
  before_action :user_params, only: [:create]
  before_action :set_user, only: [:edit, :update]
  before_action :authenticate_user!, only: [:edit, :update]

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

  def edit
    render json: { user: @user }, status: :ok
  end

  def update
    if user_params[:email].blank? || user_params[:password].blank? || user_params[:password_confirmation].blank?
      render json: { error: 'Email, password, and password confirmation are required' }, status: :unprocessable_entity
      return
    end

    unless email_valid?(user_params[:email])
      render json: { error: 'Invalid email format' }, status: :unprocessable_entity
      return
    end

    if User.where.not(id: @user.id).exists?(email: user_params[:email])
      render json: { error: 'Email is already taken' }, status: :unprocessable_entity
      return
    end

    unless password_match?
      render json: { error: 'Password confirmation does not match' }, status: :unprocessable_entity
      return
    end

    if @user.update(user_params)
      # Send confirmation email logic goes here
      render json: { message: 'User updated successfully. Please check your email to confirm.' }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  def set_user
    @user = User.find(params[:id])
  end

  def authenticate_user!
    # Authentication logic goes here
  end


  def email_valid?(email)
    email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  end

  def password_match?
    user_params[:password] == user_params[:password_confirmation]
  end
end
