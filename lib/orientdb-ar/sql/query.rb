class OrientDB::AR::Query

  attr_accessor :model, :query

  def initialize(model, query = OrientDB::SQL::Query.new)
    @model, @query = model, query
    @query.from model.oclass_name
  end

  %w{ select select! where where! and or and_not or_not order order! limit limit! range range! }.each do |name|
    define_method(name) do |*args|
      query.send name, *args
      self
    end
  end

  def all
    model.connection.all(query).map { |doc| doc.to_orientdb_ar }
  end

  def first
    model.connection.first(query).to_orientdb_ar
  end

  def results
    model.connection.all(query).map
  end

  def first_result
    model.connection.first(query)
  end

  def update(*args)
    OrientDB::AR::Update.from_query(self, *args).run
  end

  def delete
    OrientDB::AR::Delete.from_query(self).run
  end

  def inspect
    %{#<OrientDB::AR::Query:#{model.name} query="#{query.to_s}">}
  end

  alias :to_s :inspect

end

