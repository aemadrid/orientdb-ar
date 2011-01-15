class SimplePerson < OrientDB::AR::Base
  field :name, :string
end

SimplePerson.schema!
