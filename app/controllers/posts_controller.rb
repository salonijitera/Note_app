class PostsController < ApplicationController

    def index
        page = params[:page] || 1
        per_page = params[:per_page] || 10

        @posts = Post.includes(:user).page(page).per(per_page)
        @total_posts = Post.count
        @total_pages = (@total_posts.to_f / per_page).ceil

        # You can now use @posts, @total_posts, and @total_pages in your view to display the posts and pagination info
    end

    def show
        # Validate that the id is an integer
        unless params[:id].to_i.to_s == params[:id]
            return render json: { error: 'Invalid ID format' }, status: :bad_request
        end

        # Find the post with the given id, including the associated user
        @post = Post.includes(:user).find_by(id: params[:id])

        # Check if the post was found
        if @post
            # Render the post along with the user data
            render json: { post: @post, user: @post.user }
        else
            # Return an error message if the post was not found
            render json: { error: 'Post not found' }, status: :not_found
        end
    end

    def new
        @post = Post.new
    end

    def create
        @post = Post.new(post_params)
        if @post.save
            redirect_to posts_path, :notice => "Post created!!"
        else
            render 'new'
        end
    end

    def edit
        @post = Post.find(params[:id])
    end

    def update
        @post = Post.find(params[:id])
        if @post.update_attributes(post_params)
            redirect_to posts_path, :notice => "Post edited!!"
        else
            render 'edit'
        end
    end

    def delete
        @post = Post.find(params[:id])
        @post.destroy
        redirect_to posts_path, :notice => "Post deleted!!"
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

    def shop_params
        params.require(:shop).permit(:name, :address)
    end

    # Placeholder methods for user authorization and logging
    # These should be implemented according to your application's authorization and logging setup
    def user_can_edit_shop?(user, shop); end
    def log_shop_update(user_id, shop); end

    private def post_params
        params.require(:post).permit(:title, :content)
    end

end
