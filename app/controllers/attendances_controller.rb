class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overwork_consent, :update_overwork_consent, :edit_attendance_consent, :update_attendance_consent,
                                  :edit_attendance_consent, :update_attendance_consent, :confirm_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month, :update_one_month, :confirm_one_month]
  before_action :admin_or_correct_user, only:[:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :update_one_month, :edit_overwork_consent, :confirm_one_month]
  before_action :superior_without_me, only: [:edit_one_month]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  #出社・退社
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れさまでした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  # 勤怠変更を申請する
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        if item[:confirmation].present?
          attendance = Attendance.find(id)
          item[:attendance_status] = "申請中"
          @change_started_at = (attendance.worked_on.to_s + "T" + item["change_started_at(4i)"] + ":" + item["change_started_at(5i)"] + ":" + "00").to_datetime
          @change_finished_at = (attendance.worked_on.to_s + "T" + item["change_finished_at(4i)"] + ":" + item["change_finished_at(5i)"] + ":" + "00").to_datetime
          @change_finished_at = @change_finished_at.tomorrow if item[:tomorrow]
          attendance.update_attributes!(
            change_started_at: @change_started_at,
            change_finished_at: @change_finished_at,
            confirmation: item[:confirmation],
            note: item[:note],
            attendance_status: item[:attendance_status]
          )
        end
      end
    end
    flash[:success] = "１ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date]) and return
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  # 勤怠編集申請を承認する
  def edit_attendance_consent
    @attendances = Attendance.where(attendance_status: "申請中", confirmation: @user.name).order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end
  
  def update_attendance_consent
  end
  
  # 勤怠確認用ページ
  def confirm_one_month
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
  
  # 残業を申請する
  def edit_overwork_request
    @user = User.find(params[:user_id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @attendance = @user.attendances.find(params[:id])
  end
  
  def update_overwork_request
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find(params[:id])
    #時間外時間を計算する
    if params[:attendance][:tomorrow] == "true"
      tomorrow_day = @attendance.worked_on.to_date.tomorrow
      params[:attendance][:scheduled_end_time] = tomorrow_day.to_s + " " + params[:attendance][:scheduled_end_time] + ":00"
    else
      params[:attendance][:scheduled_end_time] = @attendance.worked_on.to_s + " " + params[:attendance][:scheduled_end_time] + ":00"
    end
    params[:attendance][:overtime_status] = "申請中"
    params[:attendance][:tomorrow] = "false"
    @attendance.update_attributes(overwork_params)
    flash[:success] = "残業を申請しました。"
    redirect_to @user
  end
  
  
  #残業申請を承認する
  def edit_overwork_consent
    @attendances = Attendance.where(overtime_status: "申請中", confirmation: @user.name).order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end
  
  def update_overwork_consent
    ActiveRecord::Base.transaction do
      overwork_consent_params.each do |id, item|
        if item[:change] == "true"
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
          flash[:success] = "残業申請を承認しました。"
        else
          flash[:danger] = "変更にチェックを入れて下さい。"
        end
      end
    end
    redirect_to @user
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to @user
  end
    
  
  private
  
    # 勤怠編集
    def attendances_params
      params.require(:user).permit(attendances: [:note, :confirmation, :attendance_status, :change_started_at, :change_finished_at, :tomorrow])[:attendances]
    end
    
    # 残業申請
    def overwork_params
      params.require(:attendance).permit(:scheduled_end_time, :tomorrow, :business_process, :confirmation, :overtime_status)
    end
    
    # 残業申請承認
    def overwork_consent_params
      params.require(:user).permit(attendance: [:change, :overtime_status])[:attendance]
    end
    
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end
    end
    
     # 自分以外の上長
    def superior_without_me
      @superiors = User.where(superior: true).where.not(id: @user.id)
    end
end
