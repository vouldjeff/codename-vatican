require 'spec_helper'

# TODO: fix my texts
describe TypeProperty do
  describe "validation" do    
    it "everything is ok" do
      definition_property = Factory.build(:type_property)
      definition_property.should be_valid
    end
    
    it "label requires presence" do
      definition_property = Factory.build(:type_property, :label => nil)
      definition_property.should_not be_valid
    end
    
    it "key requires presence" do
      definition_property = Factory.build(:type_property, :key => nil)
      definition_property.should_not be_valid
    end
    
    describe "range" do
      it "requires presence" do
        definition_property = Factory.build(:type_property, :range => nil)
        definition_property.should_not be_valid
      end
      
      # TODO: when the other validation is put, add specs
    end
  end
end