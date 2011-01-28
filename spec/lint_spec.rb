require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiveModel::Lint" do

  describe Person do
    it_should_behave_like AnActiveModel
  end

  describe "Dirty" do

    it "should comply" do
      @person = Person.create :name => "Uncle Bob", :age => 45
      @person.changed?.should == false

      @person.name = 'Bob'
      @person.changed?.should == true
      @person.name_changed?.should == true
      @person.name_was.should == 'Uncle Bob'
      @person.name_change.should == ['Uncle Bob', 'Bob']
      @person.name = 'Bill'
      @person.name_change.should == ['Uncle Bob', 'Bill']

      @person.save
      @person.changed?.should == false
      @person.name_changed?.should == false

      @person.name = 'Bill'
      @person.name_changed?.should == false
      @person.name_change.should == nil

      @person.name = 'Bob'
      @person.changed.should == ['name']
      @person.changes.should == {'name' => ['Bill', 'Bob']}
    end
  end

  describe "Serialization" do

    it "should comply" do
      @person = SimplePerson.new
      @person.serializable_hash.should == {"name" => nil}
      @person.as_json.should == {"name" => nil}
      @person.to_json.should == %{{"name":null}}
      @person.to_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<simple-person>\n  <name type=\"yaml\" nil=\"true\"></name>\n</simple-person>\n"

      @person.name = "Bob"
      @person.serializable_hash.should == {"name" => "Bob"}
      @person.as_json.should == {"name" => "Bob"}
      @person.to_json.should == %{{"name":"Bob"}}
      @person.to_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<simple-person>\n  <name>Bob</name>\n</simple-person>\n"
    end

  end

end
