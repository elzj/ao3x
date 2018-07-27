class WorksController < ApplicationController
  def index
  end

  def show
    @work = Work.find params[:id]
  end

  def new
  end

  def edit
  end
end
