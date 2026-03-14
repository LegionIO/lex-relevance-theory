# lex-relevance-theory

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-relevance-theory`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::RelevanceTheory`

## Purpose

Sperber and Wilson's Relevance Theory for cognitive input filtering. Relevance = cognitive_effect / processing_effort. Inputs above `ATTENTION_THRESHOLD` (0.3 normalized relevance) are worth processing; others are filtered out. Cognitive effect decays per tick; processing effort inflates (making inputs relatively less relevant over time unless reinforced). Provides attention budget reporting.

## Gem Info

- **Homepage**: https://github.com/LegionIO/lex-relevance-theory
- **License**: MIT
- **Ruby**: >= 3.4

## File Structure

```
lib/legion/extensions/relevance_theory/
  version.rb
  helpers/
    constants.rb          # INPUT_TYPES, RELEVANCE_LABELS, EFFECT_TYPES, limits, decay rates
    client.rb             # Client class (unusual placement — in helpers/)
    cognitive_input.rb    # CognitiveInput class — relevance computation
    relevance_engine.rb   # RelevanceEngine — manages inputs, attention budget
  runners/
    relevance_theory.rb   # Runner module
spec/
  helpers/cognitive_input_spec.rb
  helpers/relevance_engine_spec.rb
  runners/relevance_theory_spec.rb
```

## Key Constants

From `Helpers::Constants`:
- `MAX_INPUTS = 300`, `MAX_HISTORY = 500`, `MAX_CONTEXTS = 50`
- `DEFAULT_EFFECT = 0.5`, `DEFAULT_EFFORT = 0.5`
- `EFFECT_FLOOR = 0.0`, `EFFECT_CEILING = 1.0`, `EFFORT_FLOOR = 0.01`, `EFFORT_CEILING = 1.0`
- `EFFECT_DECAY = 0.02`, `EFFORT_INFLATION = 0.01`
- `ATTENTION_THRESHOLD = 0.3`
- `INPUT_TYPES = %i[assertion question command observation inference]`
- `EFFECT_TYPES = %i[strengthening contradiction new_implication contextual_implication elimination]`
- `RELEVANCE_LABELS`: `:maximally_relevant` (0.8+), `:highly_relevant`, `:moderately_relevant`, `:marginally_relevant`, `:irrelevant`

## Runners

| Method | Key Parameters | Returns |
|---|---|---|
| `submit_relevance_input` | `content:`, `input_type:`, `context:`, `cognitive_effect:`, `processing_effort:`, `effect_type:`, `source_id:` | `{ success:, input: }` |
| `assess_input_relevance` | `input_id:` | `{ success:, relevance:, normalized:, label:, worth_processing:, effect:, effort: }` |
| `strengthen_relevance` | `input_id:`, `amount: 0.1` | `{ success:, relevance: }` |
| `weaken_relevance` | `input_id:`, `amount: 0.1` | `{ success:, relevance: }` |
| `worth_processing_report` | — | `{ success:, inputs:, count: }` |
| `most_relevant_inputs` | `limit: 5` | `{ success:, inputs:, count: }` sorted by normalized_relevance desc |
| `context_relevance_report` | `context:` | `{ success:, context:, relevance: }` (mean relevance in context) |
| `attention_budget_report` | — | total, worth_processing, filtered_out, processing_ratio, avg_relevance |
| `update_relevance_theory` | — | decay all + prune irrelevant — `{ success:, pruned: }` |
| `relevance_theory_stats` | — | total_inputs, processable, avg_relevance, history_count |

## Helpers

### `Helpers::CognitiveInput`
Single input: `id`, `content`, `input_type`, `context`, `cognitive_effect` (clamped 0–1), `processing_effort` (clamped 0.01–1), `effect_type`, `source_id`, `created_at`. `relevance` = cognitive_effect / processing_effort. `normalized_relevance` = clamped to [0,1]. `relevance_label` mapped from `RELEVANCE_LABELS`. `worth_processing?` = normalized_relevance >= 0.3. `strengthen!(amount:)` adds to cognitive_effect. `weaken!(amount:)` reduces cognitive_effect. `decay!` applies `EFFECT_DECAY` to effect, `EFFORT_INFLATION` to effort.

### `Helpers::RelevanceEngine`
Manages `@inputs` hash + `@history`. `submit_input` creates CognitiveInput. `assess_relevance` returns full relevance breakdown. `strengthen_input` / `weaken_input` delegate. `worth_processing` / `irrelevant_inputs` filter. `most_relevant(limit:)` sorts. `by_context(context:)` / `by_effect_type(effect_type:)` filter. `context_relevance(context:)` = mean normalized_relevance for context inputs. `attention_budget` computes processing ratio. `decay_all` delegates. `prune_irrelevant` removes inputs with normalized_relevance <= 0.05.

## Integration Points

- `submit_relevance_input` processes inputs from `lex-mesh` incoming messages
- `worth_processing_report` gates which inputs reach `lex-tick`'s `sensory_processing` phase
- `attention_budget_report` can feed `lex-salience` as a processing saturation signal
- `context_relevance_report` per domain can gate `lex-curiosity` gap detection
- Inputs from `lex-swarm` task assignments can be filtered by relevance before action
- `update_relevance_theory` called each tick via `lex-cortex` phase handler

## Development Notes

- Note: `client.rb` is in `helpers/` not at the top level — unusual placement for this gem
- `relevance` = raw ratio (can exceed 1.0 when effect > effort); `normalized_relevance` clamps to [0,1]
- Effort inflation: processing_effort increases by 0.01 per decay cycle (habituating to repeated inputs)
- `prune_irrelevant` threshold: 0.05 normalized_relevance (stricter than ATTENTION_THRESHOLD = 0.3)
- Inputs evicted by oldest `created_at` when exceeding `MAX_INPUTS`
- All state is in-memory; reset on process restart
