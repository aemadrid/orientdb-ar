class Address < OrientDB::AR::Embedded
  field :street, :string
  field :city, :string
  field :state, :string
  field :zip, :string
  field :country, :string
end
