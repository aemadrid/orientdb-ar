require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Base" do
  it "should have a valid connection" do
    OrientDB::AR::Base.connection.should be_a_kind_of OrientDB::Database
  end
end
