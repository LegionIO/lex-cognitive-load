# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLoad
      module Helpers
        module Constants
          DEFAULT_CAPACITY        = 1.0
          INTRINSIC_ALPHA         = 0.15
          EXTRANEOUS_ALPHA        = 0.12
          GERMANE_ALPHA           = 0.18
          LOAD_DECAY              = 0.03
          DEFAULT_INTRINSIC       = 0.2
          DEFAULT_EXTRANEOUS      = 0.1
          DEFAULT_GERMANE         = 0.15
          OVERLOAD_THRESHOLD      = 0.85
          UNDERLOAD_THRESHOLD     = 0.25
          OPTIMAL_GERMANE_RATIO   = 0.4
          MAX_LOAD_HISTORY        = 200

          LOAD_LABELS = {
            (0.85..)      => :overloaded,
            (0.6...0.85)  => :heavy,
            (0.35...0.6)  => :optimal,
            (0.15...0.35) => :light,
            (..0.15)      => :idle
          }.freeze
        end
      end
    end
  end
end
