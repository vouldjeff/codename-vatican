require 'spec_helper'

# TODO: fix my texts
describe TypeProperty do
  describe "validation" do    
    it "everything is ok" do
      type_property = Factory.build(:type_property)
      type_property.should be_valid
    end
    
    it "label requires presence" do
      type_property = Factory.build(:type_property, :label => nil)
      type_property.should_not be_valid
    end
    
    it "key requires presence" do
      type_property = Factory.build(:type_property, :key => nil)
      type_property.should_not be_valid
    end
  end
end