class OrientDB::AR::Delete

  attr_accessor :model, :command

  def initialize(model, command = OrientDB::SQL::Delete.new)
    @model, @command = model, command
    @command.oclass model.oclass_name
  end

  %w{ oclass oclass! cluster cluster! where where! and or and_not or_not }.each do |name|
    define_method(name) do |*args|
      command.send name, *args
      self
    end
  end

  def self.from_query(query)
    obj = new query.model
    obj.command.instance_variable_set "@conditions", query.query.instance_variable_get("@conditions")
    obj
  end

  def run
    model.connection.run_command command.to_s
  end

  def inspect
    %{#<OrientDB::AR::Delete:#{model.name} command="#{command.to_s}">}
  end

  alias :to_s :inspect

end
