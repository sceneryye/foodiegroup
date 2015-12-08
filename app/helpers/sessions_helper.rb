module SessionsHelper
  def is_admin?
    [1, 2, 3, 5, 25].include? current_user.try :id
  end

  def autheorize_admin!
    redirect_to root_path unless is_admin?
  end
end
