# frozen_string_literal: true

RSpec.describe Legion::Extensions::RelevanceTheory::Helpers::RelevanceEngine do
  subject(:engine) { described_class.new }

  let(:input) { engine.submit_input(content: 'test', input_type: :assertion, context: :general) }

  describe '#submit_input' do
    it 'creates and stores an input' do
      result = engine.submit_input(content: 'hello', input_type: :observation, context: :work)
      expect(result).to be_a(Legion::Extensions::RelevanceTheory::Helpers::CognitiveInput)
      expect(result.content).to eq('hello')
    end

    it 'records history' do
      engine.submit_input(content: 'x', input_type: :assertion, context: :c)
      expect(engine.history.last[:event]).to eq(:submitted)
    end
  end

  describe '#assess_relevance' do
    it 'assesses an existing input' do
      result = engine.assess_relevance(input_id: input.id)
      expect(result[:success]).to be true
      expect(result[:relevance]).to be_a(Float)
      expect(result[:label]).to be_a(Symbol)
    end

    it 'returns not_found for missing input' do
      result = engine.assess_relevance(input_id: 'missing')
      expect(result[:success]).to be false
    end
  end

  describe '#strengthen_input' do
    it 'strengthens an existing input' do
      old_relevance = input.normalized_relevance
      result = engine.strengthen_input(input_id: input.id, amount: 0.2)
      expect(result[:success]).to be true
      expect(result[:relevance]).to be >= old_relevance
    end
  end

  describe '#weaken_input' do
    it 'weakens an existing input' do
      result = engine.weaken_input(input_id: input.id, amount: 0.2)
      expect(result[:success]).to be true
    end
  end

  describe '#worth_processing' do
    it 'returns inputs above attention threshold' do
      engine.submit_input(content: 'high', input_type: :assertion, context: :c,
                          cognitive_effect: 0.9, processing_effort: 0.1)
      engine.submit_input(content: 'low', input_type: :assertion, context: :c,
                          cognitive_effect: 0.01, processing_effort: 0.9)
      expect(engine.worth_processing.size).to eq(1)
    end
  end

  describe '#irrelevant_inputs' do
    it 'returns inputs below attention threshold' do
      engine.submit_input(content: 'low', input_type: :assertion, context: :c,
                          cognitive_effect: 0.01, processing_effort: 0.9)
      expect(engine.irrelevant_inputs.size).to eq(1)
    end
  end

  describe '#most_relevant' do
    it 'returns inputs sorted by relevance desc' do
      engine.submit_input(content: 'low', input_type: :assertion, context: :c,
                          cognitive_effect: 0.2, processing_effort: 0.8)
      high = engine.submit_input(content: 'high', input_type: :assertion, context: :c,
                                 cognitive_effect: 0.9, processing_effort: 0.1)
      result = engine.most_relevant(limit: 2)
      expect(result.first).to eq(high)
    end
  end

  describe '#by_context' do
    it 'filters by context' do
      engine.submit_input(content: 'a', input_type: :assertion, context: :work)
      engine.submit_input(content: 'b', input_type: :assertion, context: :play)
      expect(engine.by_context(context: :work).size).to eq(1)
    end
  end

  describe '#by_effect_type' do
    it 'filters by effect type' do
      engine.submit_input(content: 'a', input_type: :assertion, context: :c,
                          effect_type: :strengthening)
      engine.submit_input(content: 'b', input_type: :assertion, context: :c,
                          effect_type: :contradiction)
      expect(engine.by_effect_type(effect_type: :strengthening).size).to eq(1)
    end
  end

  describe '#context_relevance' do
    it 'returns average relevance for context' do
      engine.submit_input(content: 'a', input_type: :assertion, context: :work,
                          cognitive_effect: 0.8, processing_effort: 0.2)
      score = engine.context_relevance(context: :work)
      expect(score).to be > 0
    end

    it 'returns 0.0 for empty context' do
      expect(engine.context_relevance(context: :nonexistent)).to eq(0.0)
    end
  end

  describe '#attention_budget' do
    it 'returns budget stats' do
      engine.submit_input(content: 'x', input_type: :assertion, context: :c)
      budget = engine.attention_budget
      expect(budget).to include(:total_inputs, :worth_processing, :filtered_out,
                                :processing_ratio, :avg_relevance)
    end
  end

  describe '#decay_all' do
    it 'reduces relevance of all inputs' do
      input
      old_relevance = input.normalized_relevance
      engine.decay_all
      expect(input.normalized_relevance).to be <= old_relevance
    end
  end

  describe '#prune_irrelevant' do
    it 'removes very low relevance inputs' do
      engine.submit_input(content: 'low', input_type: :assertion, context: :c,
                          cognitive_effect: 0.01, processing_effort: 0.9)
      expect(engine.prune_irrelevant).to eq(1)
    end

    it 'does not prune relevant inputs' do
      input
      expect(engine.prune_irrelevant).to eq(0)
    end
  end

  describe '#to_h' do
    it 'returns stats hash' do
      input
      stats = engine.to_h
      expect(stats).to include(:total_inputs, :processable, :avg_relevance, :history_count)
    end
  end
end
