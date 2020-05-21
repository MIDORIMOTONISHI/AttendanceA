class BasesController < ApplicationController
  
  def index
    @bases = Base.all
    @base = Base.find(params[:id])
  end
  
  def new
    @base = Base.new
  end
  
  def show
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点登録完了しました。"
      redirect_to bases_url
    else
      render :new
    end
  end
end
