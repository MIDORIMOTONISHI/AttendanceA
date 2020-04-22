class UsersController < ApplicationController

  before_action :set_user, only:[:show]

  def new
    @user = User.new
  end
  
  def show
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "ユーザを新規作成しました。"
      redirect_to @user
    else
      render :new
    end
  end

    private

    def user_params
      params.require(:user).permit(:name, :email, :department, :code, :password, :password_confirmation)
    end
end
