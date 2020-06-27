class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overwork_consent, :update_overwork_consent, :edit_attendance_consent, :update_attendance_consent,
                                  :edit_attendance_consent, :update_attendance_consent, :confirm_one_month, :update_month_request, :edit_month_consent, :update_month_consent]
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
  
  # １ヶ月分の勤怠を申請する
  def update_month_request
    @attendance = @user.attendances.find_by(worked_on: params[:user][:first_day])
    if params[:user][:month_confirmation].present?
      @attendance.update_attributes(month_params)
      flash[:success] = "１ヶ月分の勤怠を申請しました。"
    else
      flash[:danger] = "所属長を入力してください。"
    end
    redirect_to @user
  end
  
  
  # １ヶ月分の勤怠の申請を承認する
  def edit_month_consent
    @attendances = Attendance.where(month_status: "申請中", month_confirmation: @user.name).order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end
  
  def update_month_consent
    ActiveRecord::Base.transaction do
      month_consent_params.each do |id, item|
        if item[:month_change] == "true"
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
          flash[:success] = "１ヶ月分の勤怠申請を承認しました。"
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
  

  # 勤怠編集を申請する
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        if item[:attendance_confirmation].present?
          if item["changed_started_at(4i)"].blank? || item["changed_started_at(5i)"].blank? || item[:note].blank?
            flash[:danger] = UPDATE_ERROR_MSG
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end
          attendance = Attendance.find(id)
          item[:attendance_status] = "申請中"
          @changed_started_at = attendance.worked_on.to_s + " " + item["changed_started_at(4i)"] + ":" + item["changed_started_at(5i)"] + ":" + "00"
          @changed_finished_at = attendance.worked_on.to_s + " " + item["changed_finished_at(4i)"] + ":" + item["changed_finished_at(5i)"] + ":" + "00"
          # 翌日にチェックが入っている場合
          tomorrow_day = attendance.worked_on.to_date.tomorrow
          @changed_finished_at = tomorrow_day.to_s + " " + item["changed_finished_at(4i)"] + ":" + item["changed_finished_at(5i)"] + ":" + "00" if item[:tomorrow]
          attendance.update_attributes!(
            changed_started_at: @changed_started_at,
            changed_finished_at: @changed_finished_at,
            attendance_confirmation: item[:attendance_confirmation],
            note: item[:note],
            attendance_status: item[:attendance_status]
          )
        end
      end
    end
    flash[:success] = "勤怠情報を編集しました。"
    redirect_to user_url(date: params[:date]) and return
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  
  # 勤怠編集申請を承認する
  def edit_attendance_consent
    @attendances = Attendance.where(attendance_status: "申請中", attendance_confirmation: @user.name).order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
  end
  
  def update_attendance_consent
    ActiveRecord::Base.transaction do
      change_params.each do |id, item|
        if item[:attendance_change] == "true"
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
          flash[:success] = "勤怠編集申請を承認しました。"
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
  
    # １ヶ月分の申請
    def month_params
      params.require(:user).permit(:month_status, :month_confirmation)
    end
    
    # １ヶ月分の申請承認
    def month_consent_params
      params.require(:user).permit(attendances: [:month_change, :month_status])[:attendances]
    end
  
    # 勤怠編集
    def attendances_params
      params.require(:user).permit(attendances: [:note, :attendance_confirmation, :attendance_status, :changed_started_at, :changed_finished_at, :tomorrow])[:attendances]
    end
    
    # 勤怠編集申請承認
    def change_params
      params.require(:user).permit(attendances: [:attendance_change, :attendance_status])[:attendances]
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
end
