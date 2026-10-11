# frozen_string_literal: true

RSpec.shared_examples 'a range representing table capacity' do
  it { is_expected.to allow_value(1..4).for(:capacity) }
  it { is_expected.to allow_value(4..4).for(:capacity) }

  it { is_expected.not_to allow_value(0..4).for(:capacity) }
  it { is_expected.not_to allow_value(-1..4).for(:capacity) }
  it { is_expected.not_to allow_value(4..3).for(:capacity) }
  it { is_expected.not_to allow_value(4..-1).for(:capacity) }
  it { is_expected.not_to allow_value(4..).for(:capacity) }
  it { is_expected.not_to allow_value(..4).for(:capacity) }
  it { is_expected.not_to allow_value(4).for(:capacity) }
  it { is_expected.not_to allow_value(1.5..4).for(:capacity) }
  it { is_expected.not_to allow_value(1..4.5).for(:capacity) }
end
