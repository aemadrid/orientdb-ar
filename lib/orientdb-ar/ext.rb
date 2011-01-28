require 'date'

class OrientDB::Document
  def to_orientdb_ar
    klass = getClassName.gsub('__', '::').constantize
    obj   = klass.new
    obj.instance_variable_set "@odocument", self
    obj
  end
end

class OrientDB::RecordList
  def to_orientdb_ar
    map { |x| x.respond_to?(:to_orientdb_ar) ? x.to_orientdb_ar : x }
  end
end

class OrientDB::RecordMap
  def to_orientdb_ar
    inject({ }) { |h, (k, v)| h[k] = v.respond_to?(:to_orientdb_ar) ? v.to_orientdb_ar : v; h }
  end
end

class OrientDB::RecordSet
  def to_orientdb_ar
    map { |x| x.respond_to?(:to_orientdb_ar) ? x.to_orientdb_ar : x }
  end
end

class NilClass
  def to_orientdb_ar
    self
  end
end

class Float
  def to_orientdb
    to_java
  end
end

class Java::JavaLang::Double
  def to_orientdb_ar
    to_s.to_f
  end
end

class Java::JavaUtil::Date
  def to_orientdb_ar
    ::Time.at(getTime / 1000)
  end
end

class Time
  def to_orientdb
    java.util.Date.new to_i * 1000
  end
end

class Date
  def to_orientdb
    java.util.Date.new year - 1900, month - 1, day, 0, 0, 0
  end
end

class DateTime
  def to_orientdb
    java.util.Date.new year - 1900, month - 1, day, hour, min, sec
  end
end

class Array
  def to_orientdb
    map { |x| x.respond_to?(:to_orientdb) ? x.to_orientdb : x }
  end

  def to_orientdb_ar
    map { |x| x.respond_to?(:to_orientdb_ar) ? x.to_orientdb_ar : x }
  end
end

class Hash
  def to_orientdb
    inject(java.util.HashMap.new) { |h, (k, v)| h[k.to_s] = v.respond_to?(:to_orientdb) ? v.to_orientdb : v; h }
  end

  def to_orientdb_ar
    inject({ }) { |h, (k, v)| h[k] = v.respond_to?(:to_orientdb_ar) ? v.to_orientdb_ar : v; h }
  end
end

class Java::JavaUtil::ArrayList
  def to_orientdb_ar
    map { |x| x.respond_to?(:to_orientdb_ar) ? x.to_orientdb_ar : x }
  end
end
