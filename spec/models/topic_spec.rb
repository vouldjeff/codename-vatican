require 'spec_helper'

describe Topic do
  describe "validation" do    
    it "everything is ok" do
      topic = Factory.build(:topic)
      topic.should be_valid
    end
    
    it "title requires presence" do
      topic = Factory.build(:topic, :title => nil)
      topic.should_not be_valid
    end
    
    it "description requires presence" do
      topic = Factory.build(:topic, :description => nil)
      topic.should_not be_valid
    end
    
    describe "key" do
      it "requires presence" do
        topic = Factory.build(:topic, :key => "")
        topic.should_not be_valid
      end
      
      it "requires uniqueness" do
        topic = Factory.create(:topic)
        duplicate_topic = Factory.build(:topic, :key => topic.key)
        duplicate_topic.should_not be_valid
      end
    end
  end
end