require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiveModel::Serialization" do

  it "should comply" do
    @person = SimplePerson.new
    @person.serializable_hash.should == { "name" => nil }
    @person.as_json.should == { "name" => nil }
    @person.to_json.should == %{{"name":null}}
    @person.to_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<simple-person>\n  <name type=\"yaml\" nil=\"true\"></name>\n</simple-person>\n"

    @person.name = "Bob"
    @person.serializable_hash.should == { "name" => "Bob" }
    @person.as_json.should == { "name" => "Bob" }
    @person.to_json.should == %{{"name":"Bob"}}
    @person.to_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<simple-person>\n  <name>Bob</name>\n</simple-person>\n"
  end

end
