class Api::WorksController < ApplicationController
  def index
    @search_results = WorkSearch.new(search_params).search_results
    render json: @search_results.to_json
  end

  def show
    @work = Work.find(params[:id])
  end

  def search_params
    {
      query: params[:q],
      page: params[:page] || 1
    }
  end
end
