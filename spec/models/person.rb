class Person < OrientDB::AR::Base

  field :name, :string, :not_null => true
  field :age, :int
  field :tags, [:list, :string]

  self.default_validation_group = :all

  validates_presence_of :name, :groups => :all
  validates_presence_of :age, :groups => [:all, :admins]

end
Person.schema!
