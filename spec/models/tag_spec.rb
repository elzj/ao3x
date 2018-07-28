require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe '#name' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_length_of(:name).is_at_most(100) }
  end

  describe '#to_param' do
    it "should begin with the tag id" do
      tag = Tag.new(id: 13, name: 'spooky')
      expect(tag.to_param).to eq("13-spooky")
    end

    it "should truncate very long names" do
      name = "thisisthesongthatneverends"
      tag = Tag.new(id: 66, name: name)
      expect(tag.to_param).to eq("66-thisisthesongthatneve")
    end
  end
end