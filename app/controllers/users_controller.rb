class UsersController < ApplicationController
  before_action :user_params, only: [:create, :update, :update_profile]
  before_action :set_user, only: [:edit, :update, :update_profile]
  before_action :authenticate_user!, only: [:edit, :update, :update_profile]

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

  def update_profile
    unless params[:id].to_s.match?(/\A[0-9]+\z/)
      return render json: { error: 'Wrong format.' }, status: :bad_request
    end

    return render json: { error: 'User not found.' }, status: :not_found unless @user
    return render json: { error: 'Forbidden' }, status: :forbidden unless current_user_can_edit?(@user)

    if @user.update(user_params)
      render json: { status: 200, user: @user.as_json(only: [:id, :name, :email, :updated_at]) }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    if action_name == 'create'
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    elsif action_name == 'update_profile'
      params.require(:user).permit(:name, :email)
    elsif action_name == 'update'
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    else
      params.permit(:name, :email, :password, :password_confirmation)
    end
  end

  def set_user
    @user = User.find_by(id: params[:id])
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

  def current_user_can_edit?(user)
    user == current_user || current_user.admin?
  end
end
