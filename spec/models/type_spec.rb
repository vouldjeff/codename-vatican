require 'spec_helper'

# TODO: fix my texts
describe Type do
  describe "validation" do    
    it "everything is ok" do
      definition_property = Factory.build(:type)
      definition_property.should be_valid
    end
    
    it "name requires presence" do
      definition_property = Factory.build(:type, :name => nil)
      definition_property.should_not be_valid
    end
    
    it "comment requires presence" do
      definition_property = Factory.build(:type, :comment => nil)
      definition_property.should_not be_valid
    end
    
    it "namespace requires presence" do
      definition_property = Factory.build(:type, :namespace => nil)
      definition_property.should_not be_valid
    end
    
    describe "key" do
      it "requires presence" do
        topic = Factory.build(:type, :key => nil)
        topic.should_not be_valid
      end
      
      it "requires uniqueness" do
        topic = Factory.create(:type)
        duplicate_topic = Factory.build(:type, :key => topic.key)
        duplicate_topic.should_not be_valid
      end
    end
  end
end