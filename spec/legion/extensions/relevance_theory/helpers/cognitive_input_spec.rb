# frozen_string_literal: true

RSpec.describe Legion::Extensions::RelevanceTheory::Helpers::CognitiveInput do
  subject(:input) do
    described_class.new(content: 'test input', input_type: :assertion, context: :general)
  end

  describe '#initialize' do
    it 'creates with defaults' do
      expect(input.content).to eq('test input')
      expect(input.input_type).to eq(:assertion)
      expect(input.context).to eq(:general)
      expect(input.cognitive_effect).to eq(0.5)
      expect(input.processing_effort).to eq(0.5)
    end

    it 'generates a uuid' do
      expect(input.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'clamps effect and effort' do
      clamped = described_class.new(content: 'x', input_type: :assertion, context: :c,
                                    cognitive_effect: 5.0, processing_effort: -1.0)
      expect(clamped.cognitive_effect).to eq(1.0)
      expect(clamped.processing_effort).to eq(0.01)
    end
  end

  describe '#relevance' do
    it 'returns effect / effort' do
      expect(input.relevance).to eq(1.0)
    end

    it 'is higher when effect is high and effort is low' do
      high_rel = described_class.new(content: 'x', input_type: :assertion, context: :c,
                                     cognitive_effect: 0.9, processing_effort: 0.1)
      expect(high_rel.relevance).to eq(9.0)
    end
  end

  describe '#normalized_relevance' do
    it 'clamps to 0..1' do
      high = described_class.new(content: 'x', input_type: :assertion, context: :c,
                                 cognitive_effect: 0.9, processing_effort: 0.1)
      expect(high.normalized_relevance).to eq(1.0)
    end
  end

  describe '#relevance_label' do
    it 'returns a symbol' do
      expect(input.relevance_label).to be_a(Symbol)
    end

    it 'returns :maximally_relevant for high relevance' do
      high = described_class.new(content: 'x', input_type: :assertion, context: :c,
                                 cognitive_effect: 0.9, processing_effort: 0.1)
      expect(high.relevance_label).to eq(:maximally_relevant)
    end

    it 'returns :irrelevant for low relevance' do
      low = described_class.new(content: 'x', input_type: :assertion, context: :c,
                                cognitive_effect: 0.05, processing_effort: 0.9)
      expect(low.relevance_label).to eq(:irrelevant)
    end
  end

  describe '#worth_processing?' do
    it 'is true when normalized_relevance >= threshold' do
      expect(input.worth_processing?).to be true
    end

    it 'is false when relevance is too low' do
      low = described_class.new(content: 'x', input_type: :assertion, context: :c,
                                cognitive_effect: 0.05, processing_effort: 0.9)
      expect(low.worth_processing?).to be false
    end
  end

  describe '#strengthen!' do
    it 'increases cognitive effect' do
      old_effect = input.cognitive_effect
      input.strengthen!(amount: 0.1)
      expect(input.cognitive_effect).to be > old_effect
    end
  end

  describe '#weaken!' do
    it 'decreases cognitive effect' do
      old_effect = input.cognitive_effect
      input.weaken!(amount: 0.1)
      expect(input.cognitive_effect).to be < old_effect
    end
  end

  describe '#increase_effort!' do
    it 'increases processing effort' do
      old_effort = input.processing_effort
      input.increase_effort!(amount: 0.1)
      expect(input.processing_effort).to be > old_effort
    end
  end

  describe '#decay!' do
    it 'reduces effect and increases effort' do
      old_effect = input.cognitive_effect
      old_effort = input.processing_effort
      input.decay!
      expect(input.cognitive_effect).to be < old_effect
      expect(input.processing_effort).to be > old_effort
    end
  end

  describe '#to_h' do
    it 'returns a complete hash' do
      hash = input.to_h
      expect(hash).to include(:id, :content, :input_type, :context, :cognitive_effect,
                              :processing_effort, :relevance, :normalized, :relevance_label,
                              :worth_processing, :effect_type)
    end
  end
end
