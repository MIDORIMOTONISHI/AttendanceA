class UsersController < ApplicationController

  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info,
                                  :working, :edit_overwork_request, :update_overwork_request]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :working,
                                        :edit_overwork_request, :update_overwork_request]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info, :working]
  before_action :set_one_month, only: [:show, :working, :edit_overwork_request, :update_overwork_request]

  def index
    @users = User.paginate(page: params[:page])
  end

  def import
    # fileはtmpに自動で一時保存される
    User.import(params[:file])
    flash[:success] = "ユーザーデータを登録しました。"
    redirect_to users_url
  end
  
  def new
    @user = User.new
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
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
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
      redirect_to users_url
    else
      render :edit_basic_info
    end
  end
  
  def working
    @users = User.all.includes(:attendances)
  end
  
  def edit_info
  end
  
  def edit_overwork_request
    @day = Date.parse(params[:day])
    @attendance = @user.attendances.find_by(worked_on: @day)
  end
  
  def update_overwork_request
    @attendance = @user.attendances.find_by(worked_on: @day)
    params[:attendance][:next_day] == '1' ? Time.now.tomorrow : Time.now
    @user.update_attributes(overwork_params)
    flash[:success] = "残業を申請しました。"
    redirect_to @user
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password,
                                   :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
    def overwork_params
      params.require(:user).permit(attendances: [:scheduled_end_time, :next_day, :business_process, :confirmation])[:attendances]
    end
end
