class ShopsController < ApplicationController
  before_action :authenticate_user, only: [:update]
  before_action :check_shop_owner, only: [:update]

  def update
    return render json: { error: 'Wrong format.' }, status: :bad_request unless params[:id].to_s.match?(/\A\d+\z/)
    return render json: { error: 'Shop name and address cannot be blank.' }, status: :unprocessable_entity unless validate_shop_params

    shop = Shop.find_by_id(params[:id])
    if shop.nil?
      return render json: { error: 'Shop not found.' }, status: :not_found
    end

    if shop.update(shop_params)
      render json: { status: 200, shop: shop.as_json(methods: :updated_at) }, status: :ok
    else
      render json: { error: shop.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def shop_params
    params.require(:shop).permit(:name, :address, :description)
  end

  def validate_shop_params
    params[:shop][:name].present? && params[:shop][:address].present?
  end

  def authenticate_user
    unless current_user
      render json: { error: 'You are not authenticated' }, status: :unauthorized
    end
  end

  def check_shop_owner
    shop = Shop.find_by_id(params[:id])
    unless shop && shop.owner_id == current_user.id
      render json: { error: 'You are not authorized to update this shop' }, status: :forbidden
    end
  end
end
