class Product < OrientDB::AR::Base

  field :sku, :string, :not_null => true
  field :title, :string, :not_null => true
  field :price, :float, :not_null => true

  validates_presence_of :sku, :title

end
Product.schema!
