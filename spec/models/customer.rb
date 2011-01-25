class Customer < Person
  field :number, :int, :not_null => true
  embedds_one Address, :name => :address
  embedds_many PhoneNumber, :name => :phones
end
Customer.schema!
