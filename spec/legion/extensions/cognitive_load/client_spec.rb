# frozen_string_literal: true

require 'legion/extensions/cognitive_load/client'

RSpec.describe Legion::Extensions::CognitiveLoad::Client do
  let(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a default LoadModel' do
      expect(client.load_model).to be_a(Legion::Extensions::CognitiveLoad::Helpers::LoadModel)
    end

    it 'accepts an injected load_model' do
      custom_model = Legion::Extensions::CognitiveLoad::Helpers::LoadModel.new(capacity: 0.6)
      c = described_class.new(load_model: custom_model)
      expect(c.load_model).to eq(custom_model)
      expect(c.load_model.capacity).to eq(0.6)
    end

    it 'accepts ** splat for extra kwargs' do
      expect { described_class.new(extra: :ignored) }.not_to raise_error
    end
  end

  describe 'runner method presence' do
    it 'responds to all runner methods' do
      %i[
        report_intrinsic
        report_extraneous
        report_germane
        reduce_overhead
        update_cognitive_load
        adjust_capacity
        load_status
        load_recommendation
        cognitive_load_stats
      ].each do |method|
        expect(client).to respond_to(method)
      end
    end
  end

  describe 'full cognitive load cycle' do
    it 'processes task complexity and reports a recommendation' do
      # Simulate a complex task arriving
      client.report_intrinsic(amount: 0.6, source: :task_complexity)
      client.report_extraneous(amount: 0.3, source: :poor_structure)
      client.report_germane(amount: 0.4, source: :schema_building)

      status = client.load_status
      expect(status[:status][:load_label]).to be_a(Symbol)

      rec = client.load_recommendation
      expect(rec[:recommendation]).to be_a(Symbol)
    end

    it 'reduces load over time via decay ticks' do
      client.report_intrinsic(amount: 0.9, source: :heavy_task)
      client.report_extraneous(amount: 0.8, source: :noise)

      high_ratio = client.load_model.load_ratio

      10.times { client.update_cognitive_load }

      expect(client.load_model.load_ratio).to be < high_ratio
    end

    it 'accumulates history across multiple operations' do
      client.report_intrinsic(amount: 0.5, source: :test)
      client.report_extraneous(amount: 0.3, source: :test)
      client.report_germane(amount: 0.4, source: :test)
      client.update_cognitive_load

      result = client.cognitive_load_stats
      expect(result[:history_size]).to be >= 4
    end

    it 'overhead reduction lowers extraneous' do
      client.report_extraneous(amount: 0.8, source: :noise)
      high_extraneous = client.load_model.extraneous
      client.reduce_overhead(amount: 0.3)
      expect(client.load_model.extraneous).to be < high_extraneous
    end

    it 'capacity adjustment affects load ratio' do
      client.report_intrinsic(amount: 0.5, source: :test)
      client.report_extraneous(amount: 0.3, source: :test)

      normal_ratio = client.load_model.load_ratio
      client.adjust_capacity(new_capacity: 2.0)
      expect(client.load_model.load_ratio).to be < normal_ratio
    end
  end
end
