class DraftsController < ApplicationController
  before_action :authenticate_user!

  def index
    @drafts = Draft.for_user(current_user)
  end

  def show
    @draft = Draft.for_user(current_user).find(params[:id])
  end

  def new
    @draft = Draft.for_user(current_user).first || Draft.new
  end

  def create
    id = draft_params.delete(:id)
    @draft = id.present? ? Draft.for_user(current_user).find(id) :
                           Draft.new
    unless @draft.update_from_params(draft_params)
      flash[:error] = @draft.errors.full_messages
    end

    case params[:commit]
    when "Preview Draft"
      redirect_to @draft
    when "Post Work"
      post_work
    else
      render :new
    end
  end

  def destroy
  end

  private

  def post_work(draft)
    poster = DraftPoster.new(draft)
    work = poster.post!
    if work
      redirect_to work
    else
      flash[:error] = poster.errors.to_sentence.capitalize
      render :new
    end
  end

  def draft_params
    draft_data = params.require(:draft).permit!
    draft_data.merge(user_id: current_user.id)
  end
end