# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Membership do
  let(:wedding) { create(:wedding) }
  let(:user) { create(:user, wedding:) }

  describe 'validations' do
    subject { build(:membership, user:, wedding:) }

    it { is_expected.to belong_to(:wedding) }
    it { is_expected.to belong_to(:user) }

    it do
      is_expected.to validate_uniqueness_of(:user_id)
      .case_insensitive
      .scoped_to(%i[wedding_id])
      .with_message('is already a member')
    end

    it do
      is_expected.to validate_uniqueness_of(:confirmation_token).allow_nil
    end
  end

  describe '#status' do
    context 'when the membership is neither confirmed nor expired' do
      let(:membership) { build(:membership, user:, wedding:, confirmed_at: nil, confirmation_token_expires_at: 1.hour.from_now) }

      it { expect(membership.status).to eq(:pending) }
    end

    context 'when the membership is not confirmed but expired' do
      let(:membership) { build(:membership, user:, wedding:, confirmed_at: nil, confirmation_token_expires_at: 1.hour.ago) }

      it { expect(membership.status).to eq(:expired) }
    end

    context 'when the membership is confirmed' do
      let(:membership) { build(:membership, user:, wedding:, confirmed_at: 1.hour.ago) }

      it { expect(membership.status).to eq(:active) }
    end

    context 'when there is no information (legacy)' do
      let(:membership) { build(:membership, user:, wedding:, confirmation_token: nil) }

      it { expect(membership.status).to eq(:active) }
    end

    context 'when the scenario is weird (e.g., confirmation token and future confirmation date)' do
      let(:membership) { build(:membership, user:, wedding:, confirmation_token: 'foo', confirmed_at: 1.hour.from_now) }

      it { expect { membership.status }.to raise_error('Unknown membership status') }
    end
  end
end
