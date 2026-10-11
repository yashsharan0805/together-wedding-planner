# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment do
  describe 'validations' do
    subject { build(:payment, expense:, wedding:) }

    let(:wedding) { create(:wedding) }
    let(:expense) { create(:expense, wedding:) }

    it { is_expected.to validate_presence_of(:amount) }
  end

  it { is_expected.to belong_to(:expense) }
end
