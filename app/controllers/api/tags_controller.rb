class Api::TagsController < ApplicationController
  def index
    if params[:q]
      @tags = TagSearch.new(name: params[:q]).search_results
    else
      @tags = Tag.limit(20)
      if params[:type]
        @tags = @tags.where(type: params[:type])
      end
    end
    render json: @tags.to_json
  end

  def show
    @tag = Tag.find(params[:id])
    # render json: @tag.as_json
  end

  def autocomplete
    tags = []
    options = {}
    if params[:type].present?
      options = { contexts: { typeContext: params[:type] }}
    end
    tags = TagSearch.new.suggest(
      params[:term], options
    ) if params[:term].present?
    data = tags.map{|tag| { label: tag, value: tag }}
    render json: data.to_json
  end
end
