# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module RelevanceTheory
      module Helpers
        class CognitiveInput
          include Constants

          attr_reader :id, :content, :input_type, :context, :cognitive_effect,
                      :processing_effort, :effect_type, :source_id, :created_at

          def initialize(content:, input_type:, context:, cognitive_effect: DEFAULT_EFFECT,
                         processing_effort: DEFAULT_EFFORT, effect_type: :new_implication,
                         source_id: nil)
            @id                = SecureRandom.uuid
            @content           = content
            @input_type        = input_type
            @context           = context
            @cognitive_effect  = cognitive_effect.clamp(EFFECT_FLOOR, EFFECT_CEILING)
            @processing_effort = processing_effort.clamp(EFFORT_FLOOR, EFFORT_CEILING)
            @effect_type       = effect_type
            @source_id         = source_id
            @created_at        = Time.now.utc
          end

          def relevance
            @cognitive_effect / @processing_effort
          end

          def normalized_relevance
            relevance.clamp(0.0, 1.0)
          end

          def relevance_label
            nr = normalized_relevance
            RELEVANCE_LABELS.find { |range, _| range.cover?(nr) }&.last || :irrelevant
          end

          def worth_processing?
            normalized_relevance >= ATTENTION_THRESHOLD
          end

          def strengthen!(amount: 0.1)
            @cognitive_effect = (@cognitive_effect + amount).clamp(EFFECT_FLOOR, EFFECT_CEILING)
          end

          def weaken!(amount: 0.1)
            @cognitive_effect = (@cognitive_effect - amount).clamp(EFFECT_FLOOR, EFFECT_CEILING)
          end

          def increase_effort!(amount: 0.1)
            @processing_effort = (@processing_effort + amount).clamp(EFFORT_FLOOR, EFFORT_CEILING)
          end

          def decay!
            @cognitive_effect  = (@cognitive_effect - EFFECT_DECAY).clamp(EFFECT_FLOOR, EFFECT_CEILING)
            @processing_effort = (@processing_effort + EFFORT_INFLATION).clamp(EFFORT_FLOOR, EFFORT_CEILING)
          end

          def to_h
            {
              id:                @id,
              content:           @content,
              input_type:        @input_type,
              context:           @context,
              cognitive_effect:  @cognitive_effect,
              processing_effort: @processing_effort,
              relevance:         relevance.round(3),
              normalized:        normalized_relevance.round(3),
              relevance_label:   relevance_label,
              worth_processing:  worth_processing?,
              effect_type:       @effect_type,
              source_id:         @source_id,
              created_at:        @created_at
            }
          end
        end
      end
    end
  end
end
