require 'rails_helper'

RSpec.describe DraftPoster, type: :model do
  describe '#valid?' do
    it "should return false when required data is missing" do
      poster = DraftPoster.new(Draft.new)
      expect(poster.valid?).to be_falsey
      expect(poster.errors).to eq(
        ["Title is missing", "Content is missing", "Fandom is missing", "Rating is missing", "Warning is missing", "Creator is missing"]
      )
    end
  end
  describe '#post!' do
    let(:user) do
      user = User.create(
        login: "homer",
        email: "homer@example.com",
        password: "odyssey",
        password_confirmation: "odyssey"
      )
    end
    let(:work_info) do
      {
        title: "A new work",
        content: "With plenty of content",
        fandoms: "Amazing Fandom",
        ratings: "Not Rated",
        warnings: "No Archive Warnings Apply",
        user_id: user.id
      }
    end

    context "without the right data" do
      it "should not save" do
        draft = Draft.new(work_info.merge(content: "a"))
        poster = DraftPoster.new(draft)
        expect(poster.post!).to be_falsey
        expect(poster.errors.length).to eq(1)
      end
    end
    context "with all required data" do
      it "should post a work" do
        draft = Draft.new(work_info)
        poster = DraftPoster.new(draft)
        work = poster.post!

        expect(work).not_to be_falsey
        expect(poster.errors).to be_empty
        expect(work.title).to eq("A new work")
      end
    end
  end
end
