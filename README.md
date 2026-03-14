# lex-cognitive-load

Three-component cognitive load tracker for LegionIO cognitive agents. Models intrinsic, extraneous, and germane load using Exponential Moving Average and produces actionable recommendations when the system drifts out of the optimal zone.

## What It Does

- Three EMA-tracked components: intrinsic (task complexity), extraneous (overhead/interference), germane (learning effort)
- Overload detection: total load above 85% of capacity triggers `:simplify` recommendation
- Underload detection: total load below 25% triggers `:increase_challenge` recommendation
- Excess extraneous: non-optimal germane ratio triggers `:reduce_overhead` recommendation
- Decay cycle reduces all components each tick
- Adjustable capacity ceiling for dynamic situations

## Usage

```ruby
# Report load events
runner.report_intrinsic(amount: 0.4)   # Task is complex
runner.report_extraneous(amount: 0.3)  # Distracting noise in environment
runner.report_germane(amount: 0.2)     # Actively forming new schemas

# Check current state
runner.load_status
# => { success: true, intrinsic: 0.XX, extraneous: 0.XX, germane: 0.XX,
#      total_load: 0.XX, load_ratio: 0.XX, overloaded: false, ... }

# Get recommendation
runner.load_recommendation
# => { success: true, recommendation: :reduce_overhead }

# Reduce overhead manually
runner.reduce_overhead(amount: 0.1)

# Trigger decay (called each tick)
runner.update_cognitive_load

# Full stats
runner.cognitive_load_stats
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
