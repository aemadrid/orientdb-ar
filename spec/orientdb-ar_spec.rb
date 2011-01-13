require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "OrientDB::AR" do
  it "should work" do
    OrientDB::AR::Base.connection.should be_a_kind_of OrientDB::Database

    Person.new.should be_a_kind_of Person
    Person.connection.should be_a_kind_of OrientDB::Database

    Person.oclass_name.should == 'person'
    Person.fields.keys.should == [:name, :age, :tags]
    Person.fields[:name].should == {:type => :string, :not_null => true}
    Person.fields[:age].should == {:type => :int}
    Person.fields[:tags].should == {:type => [:list, :string]}

    Person.schema!

    p = Person.create :name => "Tester Testing", :age => 45, :tags => %w{ tech_support rocks }

    p.odocument.should be_a_kind_of OrientDB::Document

    p.name.should == "Tester Testing"
    p.age.should == 45
    p.tags.should == %w{ tech_support rocks }

    p2 = Person.first :name => "Tester Testing"
    p2.name.should == p.name
    p2.age.should == p.age
#    p2.tags.should == p.tags
#    p2.should == p
  end
end
