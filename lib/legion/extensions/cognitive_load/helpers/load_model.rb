# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveLoad
      module Helpers
        class LoadModel
          include Constants

          attr_reader :intrinsic, :extraneous, :germane, :capacity, :load_history

          def initialize(capacity: DEFAULT_CAPACITY)
            @intrinsic     = DEFAULT_INTRINSIC
            @extraneous    = DEFAULT_EXTRANEOUS
            @germane       = DEFAULT_GERMANE
            @capacity      = capacity.to_f
            @load_history  = []
          end

          def total_load
            raw = @intrinsic + @extraneous + @germane
            raw.clamp(0.0, @capacity)
          end

          def load_ratio
            return 0.0 if @capacity <= 0.0

            (total_load / @capacity).clamp(0.0, 1.0)
          end

          def add_intrinsic(amount:, source: :unknown)
            @intrinsic = ema_update(@intrinsic, amount.to_f.clamp(0.0, 1.0), INTRINSIC_ALPHA)
            record_snapshot(event: :intrinsic_added, source: source)
            self
          end

          def add_extraneous(amount:, source: :unknown)
            @extraneous = ema_update(@extraneous, amount.to_f.clamp(0.0, 1.0), EXTRANEOUS_ALPHA)
            record_snapshot(event: :extraneous_added, source: source)
            self
          end

          def add_germane(amount:, source: :unknown)
            @germane = ema_update(@germane, amount.to_f.clamp(0.0, 1.0), GERMANE_ALPHA)
            record_snapshot(event: :germane_added, source: source)
            self
          end

          def reduce_extraneous(amount:)
            @extraneous = (@extraneous - amount.to_f.clamp(0.0, 1.0)).clamp(0.0, 1.0)
            record_snapshot(event: :extraneous_reduced, source: :explicit)
            self
          end

          def decay
            @intrinsic  = decay_toward(@intrinsic, DEFAULT_INTRINSIC)
            @extraneous = decay_toward(@extraneous, DEFAULT_EXTRANEOUS)
            @germane    = decay_toward(@germane, DEFAULT_GERMANE)
            record_snapshot(event: :decay, source: :tick)
            self
          end

          def adjust_capacity(new_capacity:)
            @capacity = new_capacity.to_f.clamp(0.1, 2.0)
            record_snapshot(event: :capacity_adjusted, source: :external)
            self
          end

          def overloaded?
            load_ratio >= OVERLOAD_THRESHOLD
          end

          def underloaded?
            load_ratio <= UNDERLOAD_THRESHOLD
          end

          def germane_ratio
            return 0.0 if total_load <= 0.0

            (@germane / total_load).clamp(0.0, 1.0)
          end

          def load_label
            LOAD_LABELS.each do |range, label|
              return label if range.cover?(load_ratio)
            end
            :idle
          end

          def recommendation
            return :simplify           if overloaded?
            return :increase_challenge if underloaded?
            return :reduce_overhead    if @extraneous > (@intrinsic + @germane)

            :continue
          end

          def to_h
            {
              intrinsic:      @intrinsic.round(4),
              extraneous:     @extraneous.round(4),
              germane:        @germane.round(4),
              total_load:     total_load.round(4),
              capacity:       @capacity.round(4),
              load_ratio:     load_ratio.round(4),
              germane_ratio:  germane_ratio.round(4),
              load_label:     load_label,
              overloaded:     overloaded?,
              underloaded:    underloaded?,
              recommendation: recommendation,
              history_size:   @load_history.size
            }
          end

          private

          def ema_update(current, new_value, alpha)
            ((alpha * new_value) + ((1.0 - alpha) * current)).clamp(0.0, 1.0)
          end

          def decay_toward(current, resting)
            delta = current - resting
            (current - (delta * LOAD_DECAY)).clamp(0.0, 1.0)
          end

          def record_snapshot(event:, source:)
            @load_history << {
              timestamp:  Time.now.utc,
              event:      event,
              source:     source,
              intrinsic:  @intrinsic.round(4),
              extraneous: @extraneous.round(4),
              germane:    @germane.round(4),
              load_ratio: load_ratio.round(4)
            }
            @load_history.shift while @load_history.size > MAX_LOAD_HISTORY
          end
        end
      end
    end
  end
end
