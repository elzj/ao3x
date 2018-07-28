class WorksController < ApplicationController
  def index
    @works = WorkSearch.new(search_params).search_results
  end

  def show
    @work = Work.find params[:id]
  end

  def new
  end

  def edit
  end

  def search_params
    query = {}
    query[:page] = params[:page] if params[:page]
    if params[:q].present?
      query[:query] = params[:q]
    else
      query[:sort_column] = 'revised_at'
    end
    query
  end
end
