require 'spec_helper'

describe TypeDefinitionProperty do
  describe "validation" do    
    it "everything is ok" do
      definition_property = Factory.build(:type_definition_property)
      definition_property.should be_valid
    end
    
    it "name requires presence" do
      definition_property = Factory.build(:type_definition_property, :name => nil)
      definition_property.should_not be_valid
    end
    
    describe "type name" do
      it "requires presence" do
        definition_property = Factory.build(:type_definition_property, :type_name => nil)
        definition_property.should_not be_valid
      end
      
      it "must be included in PropertyTypes" do
        definition_property = Factory.build(:type_definition_property, :type_name => "/base/invalid_type")
        definition_property.should_not be_valid
      end
    end
  end
  
  describe "method" do
    describe "build inner property" do
      definition_property = Factory.build(:type_definition_property)
      inner_property = definition_property.build_inner_property
      
      [:name, :type_name, :schema].each do |p|
        it "the #{p} attribute must be the same" do
          definition_property.send(p).should be_eql(inner_property.send(p))
        end
      end
      
    end
  end
end