class ShopsController < ApplicationController
  before_action :check_user_permission, only: [:update]

  def update
    shop = Shop.find_by_id(params[:id])
    if shop.nil?
      flash[:alert] = "Shop not found"
      redirect_to shops_path
      return
    end

    if shop.update(shop_params)
      flash[:notice] = "Shop information updated successfully"
      redirect_to shop_path(shop)
    else
      flash[:alert] = "Failed to update shop information"
      render 'edit'
    end
  end

  private

  def shop_params
    params.require(:shop).permit(:id, :name, :address)
  end

  def check_user_permission
    unless user_can_edit_shop?(current_user)
      flash[:alert] = "You are not authorized to update this shop"
      redirect_to shops_path
    end
  end
end
