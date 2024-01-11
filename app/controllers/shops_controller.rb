
class ShopsController < ApplicationController
  before_action :check_user_permission, only: [:update]

  def update
    return render json: { error: 'Invalid shop ID format.' }, status: :bad_request unless params[:id].to_s.match?(/\A\d+\z/)
    return render json: { error: 'Shop name and address cannot be blank.' }, status: :unprocessable_entity unless validate_shop_params

    shop = Shop.find_by_id(params[:id])
    if shop.nil?
      return render json: { error: 'Shop not found.' }, status: :not_found
    end

    if shop.update(shop_params)
      render json: { message: 'Shop information updated successfully', shop: shop.as_json(methods: :updated_at) }, status: :ok
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

  def check_user_permission
    unless user_can_edit_shop?(current_user, params[:id])
      render json: { error: 'You are not authorized to update this shop' }, status: :forbidden
    end
  end
end
