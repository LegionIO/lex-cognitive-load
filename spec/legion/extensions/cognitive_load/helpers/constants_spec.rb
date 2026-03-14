# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLoad::Helpers::Constants do
  subject(:mod) { described_class }

  it 'defines DEFAULT_CAPACITY as 1.0' do
    expect(mod::DEFAULT_CAPACITY).to eq(1.0)
  end

  it 'defines OVERLOAD_THRESHOLD as 0.85' do
    expect(mod::OVERLOAD_THRESHOLD).to eq(0.85)
  end

  it 'defines UNDERLOAD_THRESHOLD as 0.25' do
    expect(mod::UNDERLOAD_THRESHOLD).to eq(0.25)
  end

  it 'defines OPTIMAL_GERMANE_RATIO as 0.4' do
    expect(mod::OPTIMAL_GERMANE_RATIO).to eq(0.4)
  end

  it 'defines MAX_LOAD_HISTORY as 200' do
    expect(mod::MAX_LOAD_HISTORY).to eq(200)
  end

  it 'defines EMA alphas in (0..1)' do
    expect(mod::INTRINSIC_ALPHA).to be_between(0.0, 1.0)
    expect(mod::EXTRANEOUS_ALPHA).to be_between(0.0, 1.0)
    expect(mod::GERMANE_ALPHA).to be_between(0.0, 1.0)
  end

  it 'defines LOAD_DECAY as a small positive float' do
    expect(mod::LOAD_DECAY).to be > 0.0
    expect(mod::LOAD_DECAY).to be < 0.2
  end

  it 'defines LOAD_LABELS as a frozen hash with 5 entries' do
    expect(mod::LOAD_LABELS).to be_frozen
    expect(mod::LOAD_LABELS.size).to eq(5)
  end

  it 'LOAD_LABELS covers all label values' do
    labels = mod::LOAD_LABELS.values
    expect(labels).to include(:overloaded, :heavy, :optimal, :light, :idle)
  end

  it 'LOAD_LABELS :overloaded range covers 0.9' do
    overloaded_range = mod::LOAD_LABELS.key(:overloaded)
    expect(overloaded_range).to cover(0.9)
  end

  it 'LOAD_LABELS :idle range covers 0.1' do
    idle_range = mod::LOAD_LABELS.key(:idle)
    expect(idle_range).to cover(0.1)
  end

  it 'defines default resting values' do
    expect(mod::DEFAULT_INTRINSIC).to be_between(0.0, 1.0)
    expect(mod::DEFAULT_EXTRANEOUS).to be_between(0.0, 1.0)
    expect(mod::DEFAULT_GERMANE).to be_between(0.0, 1.0)
  end
end
