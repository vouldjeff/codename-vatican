require 'spec_helper'

# TODO: fix my texts
describe Type do
  describe "validation" do    
    it "everything is ok" do
      type = Factory.build(:type)
      type.should be_valid
    end
    
    it "name requires presence" do
      type = Factory.build(:type, :name => nil)
      type.should_not be_valid
    end
    
    it "comment requires presence" do
      type = Factory.build(:type, :comment => nil)
      type.should_not be_valid
    end
    
    it "namespace requires presence" do
      type = Factory.build(:type, :namespace => nil)
      type.should_not be_valid
    end
    
    describe "key" do
      it "requires presence" do
        topic = Factory.build(:type, :key => nil)
        topic.should_not be_valid
      end
      
      it "requires uniqueness" do
        type = Factory.create(:type)
        duplicate_type = Factory.build(:type, :key => type.key)
        duplicate_type.should_not be_valid
      end
    end
  end
end