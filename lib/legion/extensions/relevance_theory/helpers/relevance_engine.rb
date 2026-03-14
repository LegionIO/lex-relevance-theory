# frozen_string_literal: true

module Legion
  module Extensions
    module RelevanceTheory
      module Helpers
        class RelevanceEngine
          include Constants

          attr_reader :history

          def initialize
            @inputs  = {}
            @history = []
          end

          def submit_input(content:, input_type:, context:, cognitive_effect: DEFAULT_EFFECT,
                           processing_effort: DEFAULT_EFFORT, effect_type: :new_implication,
                           source_id: nil)
            evict_oldest if @inputs.size >= MAX_INPUTS

            input = CognitiveInput.new(
              content:           content,
              input_type:        input_type,
              context:           context,
              cognitive_effect:  cognitive_effect,
              processing_effort: processing_effort,
              effect_type:       effect_type,
              source_id:         source_id
            )
            @inputs[input.id] = input
            record_history(:submitted, input.id)
            input
          end

          def assess_relevance(input_id:)
            input = @inputs[input_id]
            return { success: false, reason: :not_found } unless input

            {
              success:          true,
              relevance:        input.relevance.round(3),
              normalized:       input.normalized_relevance.round(3),
              label:            input.relevance_label,
              worth_processing: input.worth_processing?,
              effect:           input.cognitive_effect,
              effort:           input.processing_effort
            }
          end

          def strengthen_input(input_id:, amount: 0.1)
            input = @inputs[input_id]
            return { success: false, reason: :not_found } unless input

            input.strengthen!(amount: amount)
            record_history(:strengthened, input_id)
            { success: true, relevance: input.normalized_relevance.round(3) }
          end

          def weaken_input(input_id:, amount: 0.1)
            input = @inputs[input_id]
            return { success: false, reason: :not_found } unless input

            input.weaken!(amount: amount)
            record_history(:weakened, input_id)
            { success: true, relevance: input.normalized_relevance.round(3) }
          end

          def worth_processing
            @inputs.values.select(&:worth_processing?)
          end

          def irrelevant_inputs
            @inputs.values.reject(&:worth_processing?)
          end

          def most_relevant(limit: 5)
            @inputs.values.sort_by { |inp| -inp.normalized_relevance }.first(limit)
          end

          def by_context(context:)
            @inputs.values.select { |inp| inp.context == context }
          end

          def by_effect_type(effect_type:)
            @inputs.values.select { |inp| inp.effect_type == effect_type }
          end

          def context_relevance(context:)
            ctx_inputs = by_context(context: context)
            return 0.0 if ctx_inputs.empty?

            ctx_inputs.sum(&:normalized_relevance) / ctx_inputs.size
          end

          def attention_budget
            processable = worth_processing
            total = @inputs.size.to_f
            {
              total_inputs:     @inputs.size,
              worth_processing: processable.size,
              filtered_out:     @inputs.size - processable.size,
              processing_ratio: total.zero? ? 0.0 : (processable.size / total).round(3),
              avg_relevance:    avg_relevance.round(3)
            }
          end

          def decay_all
            @inputs.each_value(&:decay!)
          end

          def prune_irrelevant
            ids = @inputs.select { |_id, inp| inp.normalized_relevance <= 0.05 }.keys
            ids.each { |input_id| @inputs.delete(input_id) }
            ids.size
          end

          def to_h
            {
              total_inputs:  @inputs.size,
              processable:   worth_processing.size,
              avg_relevance: avg_relevance.round(3),
              history_count: @history.size
            }
          end

          private

          def avg_relevance
            return 0.0 if @inputs.empty?

            @inputs.values.sum(&:normalized_relevance) / @inputs.size
          end

          def evict_oldest
            oldest_id = @inputs.min_by { |_id, inp| inp.created_at }&.first
            @inputs.delete(oldest_id) if oldest_id
          end

          def record_history(event, input_id)
            @history << { event: event, input_id: input_id, at: Time.now.utc }
            @history.shift while @history.size > MAX_HISTORY
          end
        end
      end
    end
  end
end
