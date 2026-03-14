# frozen_string_literal: true

module Legion
  module Extensions
    module RelevanceTheory
      module Runners
        module RelevanceTheory
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def submit_relevance_input(content:, input_type:, context:, cognitive_effect: nil,
                                     processing_effort: nil, effect_type: nil, source_id: nil, **)
            input = engine.submit_input(
              content:           content,
              input_type:        input_type.to_sym,
              context:           context.to_sym,
              cognitive_effect:  cognitive_effect || Helpers::Constants::DEFAULT_EFFECT,
              processing_effort: processing_effort || Helpers::Constants::DEFAULT_EFFORT,
              effect_type:       (effect_type || :new_implication).to_sym,
              source_id:         source_id
            )
            Legion::Logging.debug "[relevance_theory] submit id=#{input.id[0..7]} " \
                                  "type=#{input_type} relevance=#{input.normalized_relevance.round(3)}"
            { success: true, input: input.to_h }
          end

          def assess_input_relevance(input_id:, **)
            result = engine.assess_relevance(input_id: input_id)
            Legion::Logging.debug "[relevance_theory] assess id=#{input_id[0..7]} " \
                                  "relevance=#{result[:normalized]}"
            result
          end

          def strengthen_relevance(input_id:, amount: 0.1, **)
            result = engine.strengthen_input(input_id: input_id, amount: amount)
            Legion::Logging.debug "[relevance_theory] strengthen id=#{input_id[0..7]}"
            result
          end

          def weaken_relevance(input_id:, amount: 0.1, **)
            result = engine.weaken_input(input_id: input_id, amount: amount)
            Legion::Logging.debug "[relevance_theory] weaken id=#{input_id[0..7]}"
            result
          end

          def worth_processing_report(**)
            inputs = engine.worth_processing
            Legion::Logging.debug "[relevance_theory] worth_processing count=#{inputs.size}"
            { success: true, inputs: inputs.map(&:to_h), count: inputs.size }
          end

          def most_relevant_inputs(limit: 5, **)
            inputs = engine.most_relevant(limit: limit)
            Legion::Logging.debug "[relevance_theory] most_relevant count=#{inputs.size}"
            { success: true, inputs: inputs.map(&:to_h), count: inputs.size }
          end

          def context_relevance_report(context:, **)
            score = engine.context_relevance(context: context.to_sym)
            Legion::Logging.debug '[relevance_theory] context_relevance ' \
                                  "ctx=#{context} score=#{score.round(3)}"
            { success: true, context: context, relevance: score.round(3) }
          end

          def attention_budget_report(**)
            budget = engine.attention_budget
            Legion::Logging.debug '[relevance_theory] attention_budget ' \
                                  "ratio=#{budget[:processing_ratio]}"
            { success: true }.merge(budget)
          end

          def update_relevance_theory(**)
            engine.decay_all
            pruned = engine.prune_irrelevant
            Legion::Logging.debug "[relevance_theory] decay+prune pruned=#{pruned}"
            { success: true, pruned: pruned }
          end

          def relevance_theory_stats(**)
            stats = engine.to_h
            Legion::Logging.debug "[relevance_theory] stats total=#{stats[:total_inputs]}"
            { success: true }.merge(stats)
          end

          private

          def engine
            @engine ||= Helpers::RelevanceEngine.new
          end
        end
      end
    end
  end
end
