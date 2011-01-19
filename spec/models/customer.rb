class Customer < Person
  field :number, :int, :not_null => true
  has_one Address, :name => :address
  has_many PhoneNumber, :name => :phones
end
Customer.schema!
