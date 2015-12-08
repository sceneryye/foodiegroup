module SessionsHelper
  def is_admin?
    [1, 2, 3, 5, 25].include? current_user.id
  end

  def autheorize_admin!
    redirect_to to root_path unless is_admin?
  end
end
