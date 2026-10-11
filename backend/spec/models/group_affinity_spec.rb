# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupAffinity do
  subject(:affinity) { build(:group_affinity, group_a:, group_b:) }

  let(:wedding) { create(:wedding) }
  let(:group_a) { create(:group, wedding:) }
  let(:group_b) { create(:group, wedding:) }
  let(:group_c) { create(:group, wedding:) }

  describe 'validations' do
    it do
      expect(affinity).to validate_numericality_of(:discomfort)
        .is_greater_than_or_equal_to(0)
        .is_less_than_or_equal_to(2)
    end
  end

  describe '.create' do
    before do
      create(:group_affinity, group_a: group_a, group_b: group_b)
    end

    it 'disallows the creation of a group affinity with the same group on both sides' do
      expect do
        create(:group_affinity, group_a: group_c, group_b: group_c)
      end.to raise_error(ActiveRecord::StatementInvalid)
    end

    it 'disallows the creation of a group affinity that already exists' do
      expect do
        create(:group_affinity, group_a: group_a, group_b: group_b)
      end.to raise_error(ActiveRecord::StatementInvalid)
    end

    it 'disallows the creation of a group affinity with the same groups in reverse order' do
      expect do
        create(:group_affinity, group_a: group_b, group_b: group_a)
      end.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
