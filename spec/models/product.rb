class Product < OrientDB::AR::Base

  field :sku, :string, :not_null => true
  field :title, :string, :not_null => true
  field :price, :float, :not_null => true

  validates_presence_of :sku, :title

  def invoice_lines(reload = false)
    if !defined?(@invoice_lines) || reload
      @invoice_lines = InvoiceLine.where(:product => rid.lit).all
    end
    @invoice_lines
  end

end
Product.schema!
