class Person < OrientDB::AR::Base
  field :name, :string, :not_null => true
  field :age, :int
  field :tags, [:list, :string]
end
Person.schema!
