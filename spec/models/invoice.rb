class Invoice < OrientDB::AR::Base

  field :number, :int, :mandatory => true, :index => true
  links_one Customer, :not_null => true
  field :sold_on, :date
  field :total, :float
  links_many InvoiceLine, :name => :lines

  validates_presence_of :number, :customer

end
Invoice.schema!
