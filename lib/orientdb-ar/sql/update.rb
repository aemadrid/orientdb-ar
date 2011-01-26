class OrientDB::AR::Update

  attr_accessor :model, :command

  def initialize(model, command = OrientDB::SQL::Update.new)
    @model, @command = model, command
    @command.oclass model.oclass_name
  end

  %w{ oclass oclass! cluster cluster! action fields fields! values values! where where! and or and_not or_not }.each do |name|
    define_method(name) do |*args|
      command.send name, *args
      self
    end
  end

  def run
    model.connection.run_command command.to_s
  end

  def self.from_query(query, *args)
    obj = new query.model
    obj.command.instance_variable_set "@conditions", query.query.instance_variable_get("@conditions")
    obj.command.fields *args
    obj
  end

  def inspect
    %{#<OrientDB::AR::Update:#{model.name} command="#{command.to_s}">}
  end

  alias :to_s :inspect

end
