require 'spec_helper'

# TODO: fix my texts
describe Entity do
  describe "validation" do    
    it "everything is ok" do
      entity = Factory.build(:entity)
      entity.should be_valid
    end
    
    it "title requires presence" do
      entity = Factory.build(:entity, :title => nil)
      entity.should_not be_valid
    end
    
    it "description requires presence" do
      entity = Factory.build(:entity, :description => nil)
      entity.should_not be_valid
    end
    
    describe "key" do
      it "requires presence" do
        entity = Factory.build(:entity, :key => nil)
        entity.should_not be_valid
      end
      
      it "requires uniqueness" do
        entity = Factory.create(:entity)
        duplicate_entity = Factory.build(:entity, :key => entity.key)
        duplicate_entity.should_not be_valid
      end
    end
  end
end