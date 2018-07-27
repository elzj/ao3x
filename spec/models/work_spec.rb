require 'rails_helper'

RSpec.describe Work, type: :model do
  describe '#title' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it "should have extraneous whitespace removed" do
      @work = Work.new(title: " The Hobbit ")
      @work.valid?
      expect(@work.title).to eq("The Hobbit")
    end
  end
  describe '#summary' do
    it { should validate_length_of(:summary).is_at_most(1250) }
  end
  describe '#notes' do
    it { should validate_length_of(:notes).is_at_most(5000) }
  end
  describe '#endnotes' do
    it { should validate_length_of(:endnotes).is_at_most(5000) }
  end
end