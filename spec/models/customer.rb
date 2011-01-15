class Customer < Person
  field :number, :int, :not_null => true
#  field :address, Address
end
Customer.schema!
