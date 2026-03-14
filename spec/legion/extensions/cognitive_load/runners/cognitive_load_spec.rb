# frozen_string_literal: true

require 'legion/extensions/cognitive_load/client'

RSpec.describe Legion::Extensions::CognitiveLoad::Runners::CognitiveLoad do
  let(:client) { Legion::Extensions::CognitiveLoad::Client.new }

  describe '#report_intrinsic' do
    it 'returns success: true' do
      result = client.report_intrinsic(amount: 0.5)
      expect(result[:success]).to be true
    end

    it 'includes load_type: :intrinsic' do
      result = client.report_intrinsic(amount: 0.5)
      expect(result[:load_type]).to eq(:intrinsic)
    end

    it 'echoes the amount' do
      result = client.report_intrinsic(amount: 0.7, source: :task)
      expect(result[:amount]).to eq(0.7)
    end

    it 'echoes the source' do
      result = client.report_intrinsic(amount: 0.3, source: :memory)
      expect(result[:source]).to eq(:memory)
    end

    it 'includes current_state hash' do
      result = client.report_intrinsic(amount: 0.5)
      expect(result[:current_state]).to be_a(Hash)
      expect(result[:current_state]).to have_key(:load_ratio)
    end

    it 'accepts ** splat kwargs' do
      expect { client.report_intrinsic(amount: 0.5, extra_key: :ignored) }.not_to raise_error
    end
  end

  describe '#report_extraneous' do
    it 'returns success: true' do
      result = client.report_extraneous(amount: 0.3)
      expect(result[:success]).to be true
    end

    it 'includes load_type: :extraneous' do
      result = client.report_extraneous(amount: 0.3)
      expect(result[:load_type]).to eq(:extraneous)
    end

    it 'increases extraneous load on the model' do
      before = client.load_model.extraneous
      client.report_extraneous(amount: 0.8, source: :noise)
      expect(client.load_model.extraneous).to be > before
    end
  end

  describe '#report_germane' do
    it 'returns success: true' do
      result = client.report_germane(amount: 0.6)
      expect(result[:success]).to be true
    end

    it 'includes load_type: :germane' do
      result = client.report_germane(amount: 0.6)
      expect(result[:load_type]).to eq(:germane)
    end

    it 'increases germane load on the model' do
      before = client.load_model.germane
      client.report_germane(amount: 0.9, source: :learning)
      expect(client.load_model.germane).to be > before
    end
  end

  describe '#reduce_overhead' do
    it 'returns success: true' do
      result = client.reduce_overhead(amount: 0.05)
      expect(result[:success]).to be true
    end

    it 'includes before, after, and delta' do
      result = client.reduce_overhead(amount: 0.05)
      expect(result).to have_key(:before)
      expect(result).to have_key(:after)
      expect(result).to have_key(:delta)
    end

    it 'delta equals before minus after' do
      result = client.reduce_overhead(amount: 0.05)
      expect(result[:delta]).to be_within(0.0001).of(result[:before] - result[:after])
    end

    it 'accepts ** splat' do
      expect { client.reduce_overhead(amount: 0.05, extra: :ignored) }.not_to raise_error
    end
  end

  describe '#update_cognitive_load' do
    it 'returns success: true' do
      result = client.update_cognitive_load
      expect(result[:success]).to be true
    end

    it 'records action: :decay' do
      result = client.update_cognitive_load
      expect(result[:action]).to eq(:decay)
    end

    it 'includes current_state' do
      result = client.update_cognitive_load
      expect(result[:current_state]).to be_a(Hash)
    end

    it 'accepts ** splat' do
      expect { client.update_cognitive_load(extra: :ignored) }.not_to raise_error
    end
  end

  describe '#adjust_capacity' do
    it 'returns success: true' do
      result = client.adjust_capacity(new_capacity: 0.8)
      expect(result[:success]).to be true
    end

    it 'includes before and after' do
      result = client.adjust_capacity(new_capacity: 0.8)
      expect(result).to have_key(:before)
      expect(result).to have_key(:after)
    end

    it 'changes the model capacity' do
      client.adjust_capacity(new_capacity: 0.7)
      expect(client.load_model.capacity).to eq(0.7)
    end

    it 'accepts ** splat' do
      expect { client.adjust_capacity(new_capacity: 0.9, extra: :ignored) }.not_to raise_error
    end
  end

  describe '#load_status' do
    it 'returns success: true' do
      result = client.load_status
      expect(result[:success]).to be true
    end

    it 'includes a status hash' do
      result = client.load_status
      expect(result[:status]).to be_a(Hash)
    end

    it 'status includes load_label and load_ratio' do
      result = client.load_status
      expect(result[:status]).to have_key(:load_label)
      expect(result[:status]).to have_key(:load_ratio)
    end

    it 'accepts ** splat' do
      expect { client.load_status(extra: :ignored) }.not_to raise_error
    end
  end

  describe '#load_recommendation' do
    it 'returns success: true' do
      result = client.load_recommendation
      expect(result[:success]).to be true
    end

    it 'includes a recommendation symbol' do
      result = client.load_recommendation
      expect(result[:recommendation]).to be_a(Symbol)
    end

    it 'includes load metadata' do
      result = client.load_recommendation
      expect(result).to have_key(:load_label)
      expect(result).to have_key(:load_ratio)
      expect(result).to have_key(:germane_ratio)
      expect(result).to have_key(:overloaded)
      expect(result).to have_key(:underloaded)
    end

    it 'returns :simplify when overloaded' do
      c = Legion::Extensions::CognitiveLoad::Client.new
      10.times do
        c.report_intrinsic(amount: 1.0)
        c.report_extraneous(amount: 1.0)
        c.report_germane(amount: 1.0)
      end
      result = c.load_recommendation
      expect(result[:recommendation]).to eq(:simplify)
    end

    it 'accepts ** splat' do
      expect { client.load_recommendation(extra: :ignored) }.not_to raise_error
    end
  end

  describe '#cognitive_load_stats' do
    it 'returns success: true' do
      result = client.cognitive_load_stats
      expect(result[:success]).to be true
    end

    it 'includes history_size' do
      result = client.cognitive_load_stats
      expect(result).to have_key(:history_size)
    end

    it 'includes stats with avg/max/min/overload_events' do
      client.report_intrinsic(amount: 0.5)
      client.report_extraneous(amount: 0.3)
      result = client.cognitive_load_stats
      expect(result[:stats]).to have_key(:avg_load_ratio)
      expect(result[:stats]).to have_key(:max_load_ratio)
      expect(result[:stats]).to have_key(:min_load_ratio)
      expect(result[:stats]).to have_key(:overload_events)
    end

    it 'returns zero stats when history is empty' do
      c = Legion::Extensions::CognitiveLoad::Client.new
      result = c.cognitive_load_stats
      expect(result[:stats][:avg_load_ratio]).to eq(0.0)
    end

    it 'accepts ** splat' do
      expect { client.cognitive_load_stats(extra: :ignored) }.not_to raise_error
    end
  end
end
