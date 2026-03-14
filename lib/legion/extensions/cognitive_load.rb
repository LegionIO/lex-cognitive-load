# frozen_string_literal: true

require 'legion/extensions/cognitive_load/version'
require 'legion/extensions/cognitive_load/helpers/constants'
require 'legion/extensions/cognitive_load/helpers/load_model'
require 'legion/extensions/cognitive_load/runners/cognitive_load'

module Legion
  module Extensions
    module CognitiveLoad
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
