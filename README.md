# lex-relevance-theory

Relevance Theory-based cognitive input filtering for the LegionIO cognitive architecture. Scores and filters inputs by the ratio of cognitive effect to processing effort.

## What It Does

Implements Sperber and Wilson's Relevance Theory: the relevance of an input equals its cognitive effect divided by the effort required to process it. Inputs above a relevance threshold are flagged as worth processing; others are filtered out. Cognitive effect decays over time; processing effort inflates (simulating habituation to repeated inputs). Provides attention budget reporting showing what fraction of inputs merit full processing.

## Usage

```ruby
client = Legion::Extensions::RelevanceTheory::Client.new

# Submit a cognitive input
result = client.submit_relevance_input(
  content:           'Critical security event detected on gateway node',
  input_type:        :observation,
  context:           :security,
  cognitive_effect:  0.9,
  processing_effort: 0.3,
  effect_type:       :new_implication,
  source_id:         'mesh_node_42'
)
input_id = result[:input][:id]

# Assess its relevance
client.assess_input_relevance(input_id: input_id)
# => { success: true, relevance: 3.0, normalized: 1.0, label: :maximally_relevant,
#      worth_processing: true, effect: 0.9, effort: 0.3 }

# Strengthen or weaken
client.strengthen_relevance(input_id: input_id, amount: 0.05)

# Attention budget overview
client.attention_budget_report
# => { total_inputs: 10, worth_processing: 6, filtered_out: 4,
#      processing_ratio: 0.6, avg_relevance: 0.52 }

# Most relevant inputs
client.most_relevant_inputs(limit: 5)
client.worth_processing_report

# Context-specific relevance
client.context_relevance_report(context: :security)

# Periodic decay
client.update_relevance_theory
client.relevance_theory_stats
```

## Relevance Labels

`:maximally_relevant` (>= 0.8), `:highly_relevant`, `:moderately_relevant`, `:marginally_relevant`, `:irrelevant`

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
