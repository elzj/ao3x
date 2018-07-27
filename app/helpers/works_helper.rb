module WorksHelper
  def tag_list(work)
    names = []
    ['Rating', 'Warning', 'Category', 'Character', 'Relationship', 'Freeform'].each do |tag_type|
      if work.tags && work.tags[tag_type]
        names += work.tags[tag_type].pluck(:name)
      end
    end
    names.join(", ")
  end

  def render_draft_form_part
    stages = %w(content tags series collections creators extras)
    if stages.include?(params[:stage]&.downcase)
      render "drafts/#{params[:stage]}_form"
    else
      render 'drafts/basics_form'
    end
  end
end
