class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:show_about]
  before_action :authorize_user!, only: [:show_about]

  def index
    @pages = Page.all.select(:id, :name, :created_at, :updated_at)
  end

  def about
    @about_content = Page.find_by(name: 'about')&.content
  end

  def show_about
    about_page = Page.find_by(name: 'about')
    if about_page
      render json: {
        status: 200,
        page: {
          id: about_page.id,
          name: about_page.name,
          content: about_page.content,
          created_at: about_page.created_at,
          updated_at: about_page.updated_at
        }
      }, status: :ok
    else
      render json: { status: 404, error: "About page not found" }, status: :not_found
    end
  rescue => e
    render json: { status: 500, error: "Internal Server Error: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_user!
    # Assuming there's a method to check user authentication
    render json: { status: 401, error: "Unauthorized" }, status: :unauthorized unless user_signed_in?
  end

  def authorize_user!
    # Assuming there's a method to check user authorization
    render json: { status: 403, error: "Forbidden" }, status: :forbidden unless user_has_permission?(:view_about_page)
  end
end
