# frozen_string_literal: true

require 'legion/extensions/cognitive_load/helpers/constants'
require 'legion/extensions/cognitive_load/helpers/load_model'
require 'legion/extensions/cognitive_load/runners/cognitive_load'

module Legion
  module Extensions
    module CognitiveLoad
      class Client
        include Runners::CognitiveLoad

        attr_reader :load_model

        def initialize(load_model: nil, **)
          @load_model = load_model || Helpers::LoadModel.new
        end
      end
    end
  end
end
