# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLoad
      module Runners
        module CognitiveLoad
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def report_intrinsic(amount:, source: :unknown, **)
            model = load_model
            model.add_intrinsic(amount: amount, source: source)
            Legion::Logging.debug "[cognitive_load] intrinsic reported: amount=#{amount} source=#{source} " \
                                  "ratio=#{model.load_ratio.round(2)} label=#{model.load_label}"
            { success: true, load_type: :intrinsic, amount: amount, source: source, current_state: model.to_h }
          end

          def report_extraneous(amount:, source: :unknown, **)
            model = load_model
            model.add_extraneous(amount: amount, source: source)
            Legion::Logging.debug "[cognitive_load] extraneous reported: amount=#{amount} source=#{source} " \
                                  "ratio=#{model.load_ratio.round(2)} label=#{model.load_label}"
            { success: true, load_type: :extraneous, amount: amount, source: source, current_state: model.to_h }
          end

          def report_germane(amount:, source: :unknown, **)
            model = load_model
            model.add_germane(amount: amount, source: source)
            Legion::Logging.debug "[cognitive_load] germane reported: amount=#{amount} source=#{source} " \
                                  "ratio=#{model.load_ratio.round(2)} label=#{model.load_label}"
            { success: true, load_type: :germane, amount: amount, source: source, current_state: model.to_h }
          end

          def reduce_overhead(amount:, **)
            model = load_model
            before = model.extraneous
            model.reduce_extraneous(amount: amount)
            after = model.extraneous
            Legion::Logging.debug "[cognitive_load] overhead reduced: before=#{before.round(2)} after=#{after.round(2)} delta=#{(before - after).round(2)}"
            { success: true, before: before.round(4), after: after.round(4), delta: (before - after).round(4), current_state: model.to_h }
          end

          def update_cognitive_load(**)
            model = load_model
            model.decay
            snapshot = model.to_h
            Legion::Logging.debug "[cognitive_load] tick decay: ratio=#{snapshot[:load_ratio]} label=#{snapshot[:load_label]}"
            { success: true, action: :decay, current_state: snapshot }
          end

          def adjust_capacity(new_capacity:, **)
            model = load_model
            before = model.capacity
            model.adjust_capacity(new_capacity: new_capacity)
            after = model.capacity
            Legion::Logging.debug "[cognitive_load] capacity adjusted: before=#{before.round(2)} after=#{after.round(2)}"
            { success: true, before: before.round(4), after: after.round(4), current_state: model.to_h }
          end

          def load_status(**)
            model = load_model
            status = model.to_h
            Legion::Logging.debug "[cognitive_load] status: label=#{status[:load_label]} " \
                                  "overloaded=#{status[:overloaded]} underloaded=#{status[:underloaded]}"
            { success: true, status: status }
          end

          def load_recommendation(**)
            model = load_model
            rec = model.recommendation
            Legion::Logging.debug "[cognitive_load] recommendation: #{rec}"
            {
              success:        true,
              recommendation: rec,
              load_label:     model.load_label,
              load_ratio:     model.load_ratio.round(4),
              germane_ratio:  model.germane_ratio.round(4),
              overloaded:     model.overloaded?,
              underloaded:    model.underloaded?
            }
          end

          def cognitive_load_stats(**)
            model = load_model
            history = model.load_history

            stats = compute_history_stats(history)
            Legion::Logging.debug "[cognitive_load] stats: history_size=#{history.size} avg_ratio=#{stats[:avg_load_ratio]}"
            { success: true, history_size: history.size, stats: stats, current_state: model.to_h }
          end

          private

          def load_model
            @load_model ||= Helpers::LoadModel.new
          end

          def compute_history_stats(history)
            return { avg_load_ratio: 0.0, max_load_ratio: 0.0, min_load_ratio: 0.0, overload_events: 0 } if history.empty?

            ratios = history.map { |s| s[:load_ratio] }
            overload_events = history.count { |s| s[:load_ratio] >= Helpers::Constants::OVERLOAD_THRESHOLD }

            {
              avg_load_ratio:  (ratios.sum / ratios.size).round(4),
              max_load_ratio:  ratios.max.round(4),
              min_load_ratio:  ratios.min.round(4),
              overload_events: overload_events
            }
          end
        end
      end
    end
  end
end
