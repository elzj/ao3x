class DraftPoster
  REQUIRED_FIELDS = %i(title content fandoms ratings warnings creators)
  attr_reader :draft, :errors
  
  def initialize(draft)
    @draft = draft
    @errors = []
  end

  def post!
    begin
      valid? && Draft.transaction {
        work = save_work
        save_chapter(work)
        save_creatorships(work)
        save_tags(work)
        work
      }
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
      false
    end
  end

  def valid?
    REQUIRED_FIELDS.each do |field|
      if draft.send(field).blank?
        errors << "#{field.to_s.classify} is missing"
      end
    end
    errors.empty?
  end

  def save_work
    Work.new(
      draft.work_data.merge(posted: true)
    ).tap{ |work| work.save! }
  end

  def save_chapter(work)
    work.chapters.create!(draft.chapter_data.merge(posted: true))
  end

  def save_creatorships(work)
    draft.creators.each do |pseud_id|
      work.creatorships.create!(pseud_id: pseud_id)
      work.chapters.each do |chapter|
        chapter.creatorships.create!(pseud_id: pseud_id)
      end
    end
  end

  def save_tags(work)
    draft.tag_data.each_pair do |tag_type, tag_string|
      next if tag_string.blank?
      tags = Tag.process_list(tag_type, tag_string)
      tags.each do |tag|
        work.taggings.create!(tagger_id: tag.id)
      end
    end
  end
end