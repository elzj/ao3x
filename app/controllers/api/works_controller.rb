class Api::WorksController < ApplicationController
  def index
    @search_results = WorkSearch.new(search_params).search_results
    render json: @search_results.to_json
  end

  def show
    @work = Work.find(params[:id])
    chapters = @work.chapters.posted.in_order
    blurb = WorkBlurb.new(@work)
    render json: blurb.as_json.merge(
      language: Language.where(id: @work.language_id).pluck(:name).first || 'English',
      revised_at: @work.revised_at.strftime("%Y-%m-%d"),
      chapter_display: @work.chapter_total_display,
      chapters: chapters.as_json
    ).to_json
  end

  def search_params
    {
      query: params[:q],
      page: params[:page] || 1
    }
  end
end
