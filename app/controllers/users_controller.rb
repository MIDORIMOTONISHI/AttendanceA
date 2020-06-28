class UsersController < ApplicationController

  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info,
                                  :working, :edit_overwork_consent, :update_overwork_consent, :update_month_request]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :working,
                                        :edit_overwork_consent, :update_overwork_consent]
  before_action :correct_user, only: [:show, :edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info, :working, :edit_info]
  before_action :admin_user_not, only: [:show, :edit]
  before_action :set_one_month, only: [:show, :working, :edit_overwork_consent, :update_overwork_consent]

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
    @attendance = Attendance.find_by(user_id: @user, worked_on: @first_day)
    @month_notice = Attendance.where(month_status: "申請中", month_confirmation: @user.name).count
    @attendance_notice = Attendance.where(attendance_status: "申請中", attendance_confirmation: @user.name).count
    @overtime_notice = Attendance.where(overtime_status: "申請中", confirmation: @user.name).count
    @superiors = User.where(superior: true).where.not(id: @user.id)
    
    # CSV出力
    respond_to do |format|
      format.html do
          #html用の処理を書く
      end
      format.csv do
        send_data render_to_string.encode(Encoding::Windows_31J, undef: :replace, row_sep: "\r\n", force_quotes: true),
        filename: "#{@user.name}(#{l(@first_day, format: :middle)})勤怠情報.csv", type: :csv  #csv用の処理を書く(ファイル名指定)
      end
    end
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
  
  def update_month_request
  end

  
  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password,
                                   :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
end
