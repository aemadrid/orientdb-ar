class OrientDB::AR::Insert

  attr_accessor :model, :command

  def initialize(model, command = OrientDB::SQL::Insert.new)
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
    model.connection.run_command command.to_s
  end

  def inspect
    %{#<OrientDB::AR::Insert:#{model.name} command="#{command.to_s}">}
  end

  alias :to_s :inspect

end
