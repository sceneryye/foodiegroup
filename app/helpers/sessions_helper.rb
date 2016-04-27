module SessionsHelper
  def is_admin?
    current_user.try(:role) == '1'
  end

  def autheorize_admin!
    redirect_to root_path(tag: 'deal') unless is_admin?
  end
end
