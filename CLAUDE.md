# lex-cognitive-load

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Three-component cognitive load model based on Sweller's cognitive load theory. Tracks intrinsic load (task complexity inherent to the material), extraneous load (unnecessary cognitive burden from poor presentation or interference), and germane load (effort directed toward schema formation and learning). Uses Exponential Moving Average (EMA) for each component. Produces actionable recommendations when load conditions drift into overload or underload.

## Gem Info

- **Gem name**: `lex-cognitive-load`
- **Module**: `Legion::Extensions::CognitiveLoad`
- **Version**: `0.1.0`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_load/
  version.rb
  client.rb
  helpers/
    constants.rb
    load_model.rb
  runners/
    cognitive_load.rb
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `DEFAULT_CAPACITY` | `1.0` | Maximum total load budget |
| `INTRINSIC_ALPHA` | `0.15` | EMA smoothing for intrinsic component |
| `EXTRANEOUS_ALPHA` | `0.12` | EMA smoothing for extraneous component |
| `GERMANE_ALPHA` | `0.18` | EMA smoothing for germane component |
| `LOAD_DECAY` | `0.03` | Per-cycle decay applied to all components |
| `OVERLOAD_THRESHOLD` | `0.85` | Total load ratio above which overload is flagged |
| `UNDERLOAD_THRESHOLD` | `0.25` | Total load ratio below which underload is flagged |
| `OPTIMAL_GERMANE_RATIO` | `0.4` | Ideal germane fraction of total load |
| `MAX_LOAD_HISTORY` | `200` | Ring buffer size for historical load snapshots |
| `LOAD_LABELS` | range hash | From `:minimal` to `:overloaded` |

## Helpers

### `Helpers::LoadModel`
Per-agent cognitive load tracker. Holds EMA state for intrinsic, extraneous, germane, and capacity.

- `total_load` — sum of all three components
- `load_ratio` — `total_load / capacity`
- `add_intrinsic(amount)` — EMA update for intrinsic component
- `add_extraneous(amount)` — EMA update for extraneous component
- `add_germane(amount)` — EMA update for germane component
- `reduce_extraneous(amount)` — decrease extraneous directly (optimization intervention)
- `decay` — applies `LOAD_DECAY` to all three components
- `adjust_capacity(new_capacity)` — change total capacity ceiling
- `overloaded?` — `load_ratio > OVERLOAD_THRESHOLD`
- `underloaded?` — `load_ratio < UNDERLOAD_THRESHOLD`
- `germane_ratio` — germane fraction of total load
- `load_label`
- `recommendation` — returns `:simplify` (overloaded), `:increase_challenge` (underloaded), `:reduce_overhead` (excess extraneous), or `:continue` (balanced)

## Runners

Module: `Runners::CognitiveLoad`

| Runner Method | Description |
|---|---|
| `report_intrinsic(amount:)` | Add to intrinsic load via EMA |
| `report_extraneous(amount:)` | Add to extraneous load via EMA |
| `report_germane(amount:)` | Add to germane load via EMA |
| `reduce_overhead(amount:)` | Directly reduce extraneous load |
| `update_cognitive_load` | Trigger decay cycle |
| `adjust_capacity(capacity:)` | Adjust total capacity |
| `load_status` | Current load breakdown |
| `load_recommendation` | Current recommendation symbol |
| `cognitive_load_stats` | Historical stats and aggregate |

All runners return `{success: true/false, ...}` hashes.

## Integration Points

- No direct dependencies on other agentic LEX gems
- Fits `lex-tick` `action_selection` phase: overload → switch to sentinel mode or reject new tasks
- `reduce_overhead` is the natural response when `lex-conflict` escalation creates extraneous cognitive burden
- Germane load ratio feeds well-being signal to `lex-emotion`
- `lex-coldstart` imprint window represents high germane load (active schema formation)

## Development Notes

- `Client` instantiates `@load_model = Helpers::LoadModel.new`
- EMA alphas differ per component (germane fastest at 0.18, extraneous slowest at 0.12) — deliberate asymmetry to make germane load responsive and extraneous load sticky
- `recommendation` is computed purely from current state; callers decide whether to act on it
- `MAX_LOAD_HISTORY` ring buffer allows trend analysis over time
- Capacity can be adjusted dynamically (e.g., reduced when energy reserves are low)
