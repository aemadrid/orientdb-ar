require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Model" do

  describe :connection do
    it "should have a valid connection" do
      Person.connection.should be_a_kind_of OrientDB::DocumentDatabase
    end
  end

  describe :schema do
    it "should have the right schema" do
      Person.new.should be_a_kind_of Person
      Person.oclass_name.should == 'Person'
      Person.fields.keys.should == [:name, :age, :tags]
      Person.fields[:name].should == { :type => :string, :not_null => true }
      Person.fields[:age].should == { :type => :int }
      Person.fields[:tags].should == { :type => [:list, :string] }
    end
  end

  describe :attributes do
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
  end

  describe :embedded do
    it "should handle embedds_one models as relations" do
      Customer.clear
      Customer.count.should <= 0

      a  = Address.new :street => "123 S Main", :city => "Salt Lake", :state => "UT", :country => "USA"
      c1 = Customer.create :name => "Albert Einstein", :number => 1, :address => a, :age => 35
      c1.saved?.should == true
      c1.address.should == a
      c1.phones.should == []

      c2 = Customer.first
      c1.should == c2
      c2.address.should == a
      c2.phones.should == []
    end

    it "should handle embedds_many models as relations" do
      Customer.clear
      Customer.count.should <= 0

      p1 = PhoneNumber.new :number => "123456789"
      p2 = PhoneNumber.new :number => "987654321"
      c1 = Customer.create :name => "Albert Einstein", :number => 1, :phones => [p1, p2], :age => 35
      c1.saved?.should == true
      c1.address.should == nil
      c1.phones.should == [p1,p2]

      c2 = Customer.first
      c1.should == c2
      c2.address.should == nil
      c2.phones.should == [p1,p2]
    end

    it "should handle mixed embedded models as relations" do
      Customer.clear
      Customer.count.should <= 0

      a  = Address.new :street => "123 S Main", :city => "Salt Lake", :state => "UT", :country => "USA"
      p1 = PhoneNumber.new :number => "123456789"
      p2 = PhoneNumber.new :number => "987654321"
      c1 = Customer.create :name => "Albert Einstein", :number => 1, :address => a, :phones => [p1, p2], :age => 35
      c1.saved?.should == true
      c1.address.should == a
      c1.phones.should == [p1,p2]

      c2 = Customer.first
      c1.should == c2
      c2.address.should == a
      c2.phones.should == [p1,p2]
    end
  end

  describe :linked do
    it "should handle mixed linked models as relations" do
      Invoice.clear; InvoiceLine.clear; Product.clear; Customer.clear

      c1 = Customer.create :name => "Generous Buyer", :age => 38, :number => 1001
      p1 = Product.create :sku => "h1", :title => "Hammer", :price => 7.25
      p2 = Product.create :sku => "n2", :title => "9in Nail", :price => 0.12
      l1 = InvoiceLine.create :product => p1, :quantity => 1, :price => p1.price
      l2 = InvoiceLine.create :product => p2, :quantity => 10, :price => p2.price
      total = l1.quantity * l1.price + l2.quantity * l2.price
      i1 = Invoice.create :number => 417, :customer => c1, :sold_on => Date.today, :total => total, :lines => [l1, l2]
      i1.saved?.should == true
      i1.customer.should == c1
      i1.lines.should == [l1,l2]
      i1.lines[0].product.should == p1
      i1.lines[1].product.should == p2

      i2 = Invoice.first
      i2.customer.should == c1
      i2.lines.should == [l1,l2]
      i2.lines[0].product.should == p1
      i2.lines[1].product.should == p2
      i2.should == i1
    end
  end

  describe "SQL" do
    describe "query" do
      it "should find models" do
        OrientDB::SQL.monkey_patch! Symbol
        Person.clear
        Person.count.should == 0

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

    describe "update" do
      it "should update models" do
        Person.clear
        Person.count.should == 0

        p1 = Person.create :name => "Hans Solo", :age => 38, :tags => %w{ fighter pilot }
        p2 = Person.create :name => "Yoda", :age => 387, :tags => %w{ genius jedi }
        p3 = Person.create :name => "Luke Skywalker", :age => 28, :tags => %w{ jedi fighter pilot }

        Person.where(:name => "Hans Solo").update(:name => "Hans Meister")
        Person.where(:name => "Hans Meister").all.map { |x| x.rid }.should == [p1.rid]
        p1.reload
        Person.where(:name => "Hans Meister").all.should == [p1]


        Person.update(:age => 45)
        Person.where(:age => 45).all.map { |x| x.name }.should == [p1.name, p2.name, p3.name]
      end
    end

    describe "delete" do
      it "should delete models" do
        Person.delete
        Person.count.should == 0

        Person.create :name => "Hans Solo", :age => 38, :tags => %w{ fighter pilot }
        Person.create :name => "Yoda", :age => 387, :tags => %w{ genius jedi }
        Person.create :name => "Luke Skywalker", :age => 28, :tags => %w{ jedi fighter pilot }

        Person.count.should == 3

        Person.where(:name => "Hans Solo").delete
        Person.count.should == 2

        Person.delete
        Person.count.should == 0
      end
    end

    describe "insert" do
      it "should insert models" do
        Person.delete
        Person.count.should == 0

        p1 = Person.insert :name => "Hans Solo", :age => 38, :tags => %w{ fighter pilot }
        Person.count.should == 1

        p2 = Person.first
        p1.should == p2
      end
    end
  end

  describe :validations do
    it "should validate models correctly" do
      Person.delete
      Person.count.should == 0

      p1 = Person.new
      p1.save.should == false
      p1.errors.size.should == 2
      p1.errors.keys.should == [:name, :age]
      p1.errors[:name].should == ["can't be empty"]
      p1.errors[:age].should == ["can't be empty"]

      p1.name = "Tester"
      p1.valid?.should == false
      p1.errors.size.should == 1
      p1.errors[:age].should == ["can't be empty"]

      p1.age = 25
      p1.valid?.should == true
      p1.errors.size.should == 0

      p1.save.should == true
    end
  end

  describe :validate_embedded do
    it "should validate properly with embedded documents" do
      Customer.clear

      c1 = Customer.new :name => "Tester", :age => 37
      c1.valid?.should == true

      c1.build_address :street => "4647 Pagentry", :city => "Sandy"
      c1.valid?.should == false
      c1.errors.size.should == 1
      c1.errors[:address].should == ["-1:-1 State can't be empty"]
    end
  end
end
