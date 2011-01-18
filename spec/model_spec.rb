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

  it "should create working models" do
    p = Person.create :name => "Tester Testing", :age => 45, :tags => %w{ tech_support rocks }

    p.name.should == "Tester Testing"
    p.age.should == 45
    p.tags.should == %w{ tech_support rocks }

    p2 = Person.first :name => "Tester Testing"
    p2.name.should == p.name
    p2.age.should == p.age
    p2.tags.map.should == p.tags
  end

  it "should find models" do
    OrientDB::SQL.monkey_patch! Symbol
    Person.clear

    p1 = Person.create :name => "Hans Solo", :age => 38, :tags => %w{ fighter pilot }
    p2 = Person.create :name => "Yoda", :age => 387, :tags => %w{ genius jedi }
    p3 = Person.create :name => "Luke Skywalker", :age => 28, :tags => %w{ jedi fighter pilot }
    p4 = Person.create :name => "Princess Leia", :age => 28, :tags => %w{ fighter royalty }
    p5 = Person.create :name => "Chewbaca", :age => 53, :tags => %w{ fighter brave hairy }

    Person.where(:name.like('%w%')).all.should == [p3, p5]
    Person.where(:age.gt(28), :age.lt(75)).all.should == [p1, p5]
    Person.where("'jedi' IN tags").all.should == [p2, p3]
    Person.where("'fighter' IN tags", :age.lte(28)).order(:name.desc).all.first.should == p4
  end
end
