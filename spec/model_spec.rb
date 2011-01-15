require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Model" do
  it "should have a valid connection" do
    Person.connection.should be_a_kind_of OrientDB::Database
  end

  it "should have the right schema" do
    Person.new.should be_a_kind_of Person
    Person.oclass_name.should == 'Person'
    Person.fields.keys.should == [:name, :age, :tags]
    Person.fields[:name].should == {:type => :string, :not_null => true}
    Person.fields[:age].should == {:type => :int}
    Person.fields[:tags].should == {:type => [:list, :string]}
  end

  it "should " do
    p = Person.create :name => "Tester Testing", :age => 45, :tags => %w{ tech_support rocks }

    p.name.should == "Tester Testing"
    p.age.should == 45
    p.tags.should == %w{ tech_support rocks }

    p2 = Person.first :name => "Tester Testing"
    p2.name.should == p.name
    p2.age.should == p.age
    p2.tags.map.should == p.tags
  end
end
