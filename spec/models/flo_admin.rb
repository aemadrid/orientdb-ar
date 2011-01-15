module Flo
  class Admin < ::Person
    field :login, :string
    field :password, :string
  end
end
Flo::Admin.schema!
