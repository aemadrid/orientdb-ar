$LOAD_PATH.unshift(File.dirname(__FILE__))

module OrientDB
  module AR
  end
end

require 'model/document_mixin'
require 'model/base'
require 'model/embedded'
require 'model/ext'
