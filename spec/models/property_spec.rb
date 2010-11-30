require 'spec_helper'

Type.all.each(&:destroy)
Topic.all.each(&:destroy)

describe Property do
  describe "validation" do    
    it "everything is ok" do
      property = Factory.build(:property)
      property.should be_valid
    end
    
    it "name requires presence" do
      property = Factory.build(:property, :name => nil)
      property.should_not be_valid
    end
    
    describe "key" do
      it "requires presence" do
        property = Factory.build(:property, :key => nil)
        property.should_not be_valid
      end
      
      #it "must be included in PropertyTypes" do
        #property = Factory.build(:property, :key => "/base/invalid_type")
        #property.should_not be_valid
      #end
    end
  end
  
  describe "method" do
    describe "initialize_from_type()" do
      type0 = Factory.create(:type)
      type = Factory.create(:type)
      topic = Factory.build(:topic)
      type.inherits << type0._id # TODO: change to key
      type.save
      
      describe "with normal call" do
        property = Property.initialize_from_type(type.key, topic)
        
        [:name, :key].each do |p|
          it "#{p} must remain the same" do
            property.send(p).should be_eql(type.send(p))
          end
        end
        
        it "inner_properties must remain the same as type_definition_properties" do
          property.inner_properties.length.should be_eql(type.type_definition_properties.length)
          [:name, :type_name, :schema, :is_array].each do |p|
            property.inner_properties.collect(&p).should be_eql(type.type_definition_properties.collect(&p))
          end
        end
      end
      
      describe "with errors" do
        it "must raise ArgumentError on nil type key" do
          lambda { Property.initialize_from_type(nil, topic) }.should raise_error(ArgumentError)
        end
        
        it "must raise ArgumentError on non String type key" do
          lambda { Property.initialize_from_type(1, topic) }.should raise_error(ArgumentError)
        end
        
        it "must raise UnknownTypeError on type key which is not in the database" do
          lambda { Property.initialize_from_type("/errors/error", topic) }.should raise_error(UnknownTypeError)
        end
      end
      type.destroy
      type0.destroy
      topic.destroy
    end
  end
end