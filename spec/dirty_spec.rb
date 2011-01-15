require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiveModel" do

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

end
