# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineStat do
  describe 'validations' do
    subject { build(:engine_stat, tables_arrangement:) }

    let(:tables_arrangement) { create(:tables_arrangement) }

    it { is_expected.to validate_presence_of(:iteration) }
    it { is_expected.to validate_presence_of(:evaluation_count) }
    it { is_expected.to validate_presence_of(:real_time) }
    it { is_expected.to validate_presence_of(:system_time) }
    it { is_expected.to validate_presence_of(:user_time) }
    it { is_expected.to validate_presence_of(:total_time) }

    it { is_expected.to validate_uniqueness_of(:iteration).scoped_to(:tables_arrangement_id) }
  end
end
