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
    @draft = Draft.for_user(current_user).find(id) if id.present?
    if draft_params[:media]
      @draft.media = draft_params.delete(:media)
    end
    @draft.set_data(draft_params) if @draft
    @draft ||= Draft.new(draft_params)
    @draft.save!

    case params[:commit]
    when "Preview Draft"
      redirect_to @draft
    when "Post Work"
      poster = DraftPoster.new(@draft)
      work = poster.post!
      if work
        redirect_to work
      else
        flash[:error] = poster.errors.to_sentence.titleize
        render :new
      end
    else
      render :new
    end
  end

  def destroy
  end

  private

  def draft_params
    draft_data = params.require(:draft).permit!
    draft_data.merge(user_id: current_user.id)
  end
end