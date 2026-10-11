# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings do
  describe 'callbacks' do
    let(:wedding) { create(:wedding) }

    it { expect(wedding.settings.invitation_config).to be_a(InvitationConfig) }
  end
end
