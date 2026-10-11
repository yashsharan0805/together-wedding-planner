# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AffinityGroupsHierarchy do
  describe '#discomfort' do
    subject { described_class.new.discomfort(group_a, group_b) }

    context 'when checking a group with itself' do
      let(:group_a) { SecureRandom.uuid }
      let(:group_b) { group_a }

      it { is_expected.to be_zero }
    end

    context 'when one one of the groups is nil' do
      let(:group_a) { SecureRandom.uuid }
      let(:group_b) { nil }

      it { is_expected.to eq(described_class::DEFAULT_DISCOMFORT) }
    end
  end
end
