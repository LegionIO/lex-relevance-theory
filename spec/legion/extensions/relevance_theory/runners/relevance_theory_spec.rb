# frozen_string_literal: true

RSpec.describe Legion::Extensions::RelevanceTheory::Runners::RelevanceTheory do
  let(:client) { Legion::Extensions::RelevanceTheory::Helpers::Client.new }

  describe '#submit_relevance_input' do
    it 'submits an input' do
      result = client.submit_relevance_input(content: 'test', input_type: :assertion, context: :work)
      expect(result[:success]).to be true
      expect(result[:input][:content]).to eq('test')
    end
  end

  describe '#assess_input_relevance' do
    it 'assesses an input' do
      created = client.submit_relevance_input(content: 'x', input_type: :assertion, context: :c)
      result = client.assess_input_relevance(input_id: created[:input][:id])
      expect(result[:success]).to be true
      expect(result[:label]).to be_a(Symbol)
    end
  end

  describe '#strengthen_relevance' do
    it 'strengthens an input' do
      created = client.submit_relevance_input(content: 'x', input_type: :assertion, context: :c)
      result = client.strengthen_relevance(input_id: created[:input][:id])
      expect(result[:success]).to be true
    end
  end

  describe '#weaken_relevance' do
    it 'weakens an input' do
      created = client.submit_relevance_input(content: 'x', input_type: :assertion, context: :c)
      result = client.weaken_relevance(input_id: created[:input][:id])
      expect(result[:success]).to be true
    end
  end

  describe '#worth_processing_report' do
    it 'returns processable inputs' do
      result = client.worth_processing_report
      expect(result[:success]).to be true
    end
  end

  describe '#most_relevant_inputs' do
    it 'returns top relevant inputs' do
      client.submit_relevance_input(content: 'a', input_type: :assertion, context: :c)
      result = client.most_relevant_inputs(limit: 3)
      expect(result[:success]).to be true
    end
  end

  describe '#context_relevance_report' do
    it 'returns context relevance score' do
      client.submit_relevance_input(content: 'a', input_type: :assertion, context: :work)
      result = client.context_relevance_report(context: :work)
      expect(result[:success]).to be true
      expect(result[:relevance]).to be_a(Float)
    end
  end

  describe '#attention_budget_report' do
    it 'returns attention budget stats' do
      result = client.attention_budget_report
      expect(result[:success]).to be true
      expect(result).to include(:total_inputs, :processing_ratio)
    end
  end

  describe '#update_relevance_theory' do
    it 'decays and prunes' do
      result = client.update_relevance_theory
      expect(result[:success]).to be true
      expect(result).to have_key(:pruned)
    end
  end

  describe '#relevance_theory_stats' do
    it 'returns stats' do
      result = client.relevance_theory_stats
      expect(result[:success]).to be true
      expect(result).to include(:total_inputs, :processable)
    end
  end
end
