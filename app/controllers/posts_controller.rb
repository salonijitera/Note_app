class PostsController < ApplicationController
  before_action :validate_id_format, only: [:show, :update, :edit_post, :show_post]

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    @posts = Post.includes(:user).page(page).per(per_page)
    @total_posts = Post.count
    @total_pages = (@total_posts.to_f / per_page).ceil
    render json: { status: 200, posts: @posts, total_posts: @total_posts, total_pages: @total_pages }
  rescue => e
    render json: { error: 'Internal Server Error', message: e.message }, status: :internal_server_error
  end

  def show
    @post = Post.includes(:user).find_by(id: params[:id])
    if @post
      render json: { post: @post, user: @post.user }
    else
      render json: { error: 'Post not found' }, status: :not_found
    end
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params.merge(created_at: Time.current, updated_at: Time.current))
    if post_params_valid? && @post.save
      render json: { id: @post.id, title: @post.title, content: @post.content }, status: :created
    else
      render json: { error: 'Validation failed', messages: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find_by_id(params[:id])
    if @post.nil?
      render json: { error: 'Post not found' }, status: :not_found
    elsif post_params_valid? && @post.update_attributes(post_params)
      redirect_to posts_path, notice: "Post edited!!"
    else
      render 'edit'
    end
  end

  def delete
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: "Post deleted!!"
  end

  # The `edit_post` method is renamed to `show_post` to resolve the conflict
  def show_post
    @post = Post.find_by(id: params[:id])
    if @post
      render json: { status: 200, post: @post }, status: :ok
    else
      render json: { error: 'Post not found' }, status: :not_found
    end
  rescue StandardError => e
    render json: { error: 'An unexpected error occurred' }, status: :internal_server_error
  end

  def update_shop
    shop = Shop.find_by_id(params[:id])
    return render json: { error: 'Shop not found' }, status: :not_found unless shop

    if user_can_edit_shop?(current_user, shop)
      if shop.update(shop_params)
        log_shop_update(current_user.id, shop)
        render json: { id: shop.id, name: shop.name, address: shop.address, status: 'Update successful' }, status: :ok
      else
        render json: { errors: shop.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'User not authorized to update shop' }, status: :forbidden
    end
  end

  private

  def post_params_valid?
    required_params = %i[title content user_id]
    required_params.all? { |param| post_params[param].present? } && User.exists?(post_params[:user_id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :user_id)
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :bad_request
    false
  rescue StandardError => e
    render json: { error: 'An unexpected error occurred' }, status: :internal_server_error
    false
  end

  def shop_params
    params.require(:shop).permit(:name, :address)
  end

  def validate_id_format
    unless params[:id].to_s.match?(/\A\d+\z/)
      render json: { error: 'Invalid ID format' }, status: :bad_request
    end
  end

  # Placeholder methods for user authorization and logging
  # These should be implemented according to your application's authorization and logging setup
  def user_can_edit_shop?(user, shop); end
  def log_shop_update(user_id, shop); end
end
