class PhoneNumber < OrientDB::AR::Embedded
  field :type, :string
  field :number, :string
  field :extension, :string
end