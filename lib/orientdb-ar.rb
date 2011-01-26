$LOAD_PATH.unshift(File.dirname(__FILE__))

module OrientDB
  module AR
  end
end

require 'orientdb-ar/document_mixin'
require 'orientdb-ar/base'
require 'orientdb-ar/embedded'
require 'orientdb-ar/ext'

OrientDB::SQL.monkey_patch!