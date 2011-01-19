class OrientDB::AR::Query

  attr_accessor :model, :query

  def initialize(model, query = OrientDB::SQL::Query.new)
    @model, @query = model, query
    @query.from model.name
  end

  %w{ select select! where where! and or and_not or_not order order! limit limit! range range! }.each do |name|
    define_method(name) do |*args|
      query.send name, *args
      self
    end
  end

  def all
    model.connection.query(query).map { |doc| model.new_from_doc doc }
  end

  def first
    model.new_from_doc model.connection.first(query)
  end

  def results
    model.connection.query(query).map
  end

  def inspect
    %{#<OrientDB::AR::Query:#{model.name} query="#{query.to_s}">}
  end

  alias :to_s :inspect

end

