require 'spec_helper'

describe DocumentRef do
  describe "self.build()" do
    type0 = Factory.create(:type)
    
    describe "without errors" do
      type = Factory.create(:type_with_ref)
      definition_property = "ref" # TODO: fix... depends in some way from the factory definition....
      document_ref = DocumentRef.build(type0.key, type.key, definition_property)

      it "must build proper object" do
        document_ref.type.should be_eql(type0.key)
        document_ref.referenced_type.should be_eql(type.key)
        document_ref.referenced_property.should be_eql(definition_property)
      end
    end
    
    describe "with errors" do 
      type = Factory.create(:type)  
        
      it "must raise ArgumentError on nil type" do
        lambda { DocumentRef.build(nil, nil, nil) }.should raise_error(ArgumentError)
      end
      
      it "must raise UnknownTypeError on type which is not in the database" do
        lambda { DocumentRef.build("/invalids/invalid", nil, nil) }.should raise_error(UnknownTypeError)
      end
      
      it "must raise UnknownTypeError on type with definition_property which was not found in the database" do
        lambda { DocumentRef.build(type.key0, "/invalids/invalid", "Invalid") }
      end
      
      it "must raise UnknownTypeError on type in the database with definition_property which was not found in the database" do
        lambda { DocumentRef.build(type.key0, type.key, "Invalid") }
      end
      
      it "must raise UnknownTypeError on valid type, but definition_property whose type_name is not DocumentRef" do
        lambda { DocumentRef.build(type.key0, type.key, type.type_definition_properties.first.name) }
      end
    end
  end
end