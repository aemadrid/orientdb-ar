class InvoiceLine < OrientDB::AR::Base

  links_one Product, :not_null => true
  field :quantity, :int, :not_null => true
  field :price, :float, :not_null => true

  validates_presence_of :product, :quantity

end
InvoiceLine.schema!
