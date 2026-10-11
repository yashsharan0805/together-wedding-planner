# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group do
  describe 'validations' do
    subject { build(:group) }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to(%i[wedding_id]) }
  end

  describe 'callbacks' do
    let_it_be(:wedding) { create(:wedding) }
    before do
      allow(wedding).to receive(:needs_optimization!)
    end

    it 'sets color before create' do
      expect(create(:group).color).to be_present
    end

    it 'triggers optimization when destroyed' do
      create(:group, wedding:).destroy

      expect(wedding).to have_received(:needs_optimization!)
    end
  end

  describe 'relations' do
    it 'removes group affinities on cascade' do
      wedding = create(:wedding)
      group_a = create(:group, wedding:, name: 'A')
      group_b = create(:group, wedding:, name: 'B')

      create(:group_affinity, group_a:, group_b:)

      expect { group_a.destroy }
        .to change(described_class, :count).from(2).to(1)
        .and change(GroupAffinity, :count).from(1).to(0)
    end

    describe 'parent group deletion' do
      let(:wedding) { create(:wedding) }
      let(:parent) { create(:group, wedding:) }

      before do
        create(:group, wedding:, parent:)
        create(:group, wedding:, parent:)
      end

      it 'nullifies children groups (destroy)' do
        expect { parent.destroy }.to change { wedding.groups.count }.from(3).to(2)

        expect(wedding.groups.pluck(:parent_id)).to all be_nil
      end

      it 'nullifies children groups (delete)' do
        expect { parent.delete }.to change { wedding.groups.count }.from(3).to(2)

        expect(wedding.groups.pluck(:parent_id)).to all be_nil
      end
    end
  end
end
