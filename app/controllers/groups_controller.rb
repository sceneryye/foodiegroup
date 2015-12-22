class GroupsController < ApplicationController
  def show
    @group = Group.find(params[:id])
    @group_admin = User.find(@group.user_id)
    @group_member = User.where(group_id: params[:id])
  end

  def update
    group = Group.find(params[:id])
    if group.update(group_params)
      return render text: 'success'
    else
      return render text: 'fail'
    end
  end

  private

  def group_params
    params.permit(:group_desc, :name)
  end
end
