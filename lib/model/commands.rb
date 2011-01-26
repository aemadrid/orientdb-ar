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
    model.connection.run_command command
  end

  def self.from_query(query, *args)
    obj = new query.model
    obj.command.instance_variable_set "@conditions", @conditions
    obj.command.fields *args
  end

  def inspect
    %{#<OrientDB::AR::Update:#{model.name} command="#{command.to_s}">}
  end

  alias :to_s :inspect

end

class OrientDB::AR::Insert

  attr_accessor :model, :command

  def initialize(model, command = OrientDB::SQL::Update.new)
    @model, @command = model, command
    @command.oclass model.oclass_name
  end

  %w{ oclass oclass! cluster cluster! fields fields! values values! }.each do |name|
    define_method(name) do |*args|
      command.send name, *args
      self
    end
  end

  def run
    model.connection.run_command command
  end

  def self.from_query(query, *args)
    obj = new query.model
    obj.command.fields *args
  end

  def inspect
    %{#<OrientDB::AR::Insert:#{model.name} command="#{command.to_s}">}
  end

  alias :to_s :inspect

end

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

  def run
    model.connection.run_command command
  end

  def self.from_query(query, *args)
    obj = new query.model
    obj.command.instance_variable_set "@conditions", @conditions
    obj.command.fields *args
  end

  def inspect
    %{#<OrientDB::AR::Update:#{model.name} command="#{command.to_s}">}
  end

  alias :to_s :inspect

end
