# frozen_string_literal: true

require_relative 'relevance_theory/version'
require_relative 'relevance_theory/helpers/constants'
require_relative 'relevance_theory/helpers/cognitive_input'
require_relative 'relevance_theory/helpers/relevance_engine'
require_relative 'relevance_theory/runners/relevance_theory'
require_relative 'relevance_theory/helpers/client'

module Legion
  module Extensions
    module RelevanceTheory
      extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core)
    end
  end
end
