# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it { is_expected.to validate_length_of(:language).is_equal_to(2).allow_nil }
  end

  describe '.reset_password_frontend_url' do
    it 'generates the frontend app URL where the user can reset their password' do
      expect(described_class.reset_password_frontend_url(slug: 'foo', reset_password_token: :bar))
        .to eq('http://www.example.com/foo/reset-password?reset_password_token=bar')
    end
  end
end
