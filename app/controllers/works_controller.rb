class WorksController < ApplicationController
  def index
    @works = WorkSearch.new(search_params).search_results
    if @works[:error]
      flash[:error] = @works[:error]
    end
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
    if params[:tag_id]
      @tag = Tag.find(params[:tag_id])
      query[:filter_ids] = [@tag.id]
    end
    if params[:q].present?
      query[:query] = params[:q]
    else
      query[:sort_column] = 'revised_at'
    end
    query
  end
end
