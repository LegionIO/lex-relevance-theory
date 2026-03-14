# frozen_string_literal: true

module Legion
  module Extensions
    module RelevanceTheory
      module Helpers
        module Constants
          # Relevance = cognitive_effect / processing_effort
          # Higher effect + lower effort = more relevant

          INPUT_TYPES = %i[assertion question command observation inference].freeze

          RELEVANCE_LABELS = {
            (0.8..)     => :maximally_relevant,
            (0.6...0.8) => :highly_relevant,
            (0.4...0.6) => :moderately_relevant,
            (0.2...0.4) => :marginally_relevant,
            (..0.2)     => :irrelevant
          }.freeze

          EFFECT_TYPES = %i[
            strengthening contradiction new_implication contextual_implication elimination
          ].freeze

          MAX_INPUTS   = 300
          MAX_HISTORY  = 500
          MAX_CONTEXTS = 50

          DEFAULT_EFFECT  = 0.5
          DEFAULT_EFFORT  = 0.5
          EFFECT_FLOOR    = 0.0
          EFFECT_CEILING  = 1.0
          EFFORT_FLOOR    = 0.01
          EFFORT_CEILING  = 1.0

          # Decay rates
          EFFECT_DECAY = 0.02
          EFFORT_INFLATION = 0.01

          # Attention allocation: inputs above this threshold get processed
          ATTENTION_THRESHOLD = 0.3
        end
      end
    end
  end
end
