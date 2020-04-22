module SessionsHelper
  # 引数に渡されたユーザーオブジェクトでログイン
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # 現在ログイン中のユーザがいればオブジェクトを返す
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
  
  # ログイン中のユーザがいればtrueを返す
  def logged_in?
    !current_user.nil?
  end
  
  # セッションと@current_userを破棄する
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
