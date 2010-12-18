require 'spec_helper'

describe TypeProperty do
  describe "validation" do    
    it "everything is ok" do
      definition_property = Factory.build(:type_property)
      definition_property.should be_valid
    end
    
    it "name requires presence" do
      definition_property = Factory.build(:type_property, :label => "")
      definition_property.should_not be_valid
    end
    
    describe "range" do
      it "requires presence" do
        definition_property = Factory.build(:type_property, :range => "")
        definition_property.should_not be_valid
      end
      
      #it "must be included in PropertyTypes" do
      #  definition_property = Factory.build(:type_property, :range => "RDF::URI")
      #  definition_property.should_not be_valid
      #end
    end
  end
end