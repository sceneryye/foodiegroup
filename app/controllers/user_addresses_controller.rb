#encoding:utf-8
class UserAddressesController < ApplicationController
  before_action :validate_user!
  before_action only: [:show, :edit, :update, :destroy] do
    validate_permission!(set_user_address.user)
  end
  before_action :set_user_address, only: [:edit, :update, :destroy]

  def new
    @user_address = UserAddress.new
  end

  def create
    @user_address = UserAddress.new(user_address_params)
    @user_address.user = current_user

    if@user_address.save
      redirect_to user_addresses_path, notice: '地址添加成功'
    else
      render :new
    end
  end

  def show
    @user_address = UserAddress.find(params[:id])
  end

  def edit() end

  def update
    if @user_address.update(user_address_params)
      redirect_to user_addresses_path, notice: '地址修改成功'
    else
      render :edit
    end
  end

  def destroy
   @user_address.destroy
    respond_to do |format|
      format.html {redirect_to user_addresses_path, notice: '地址删除成功'}
      format.js
    end    
  end

  def index
    @user_addresses = current_user.user_addresses
    @user_address = UserAddress.new
  end

  private
  def set_user_address
    @user_address = UserAddress.find(params[:id])
  end

  def user_address_params
    params.require(:user_address).permit(:name, :address, :mobile, :area, :default)
  end
end
