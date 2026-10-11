# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invitation do
  describe '#url' do
    let(:wedding) { create(:wedding, slug: 'test-wedding') }
    let(:invitation) { create(:invitation, wedding:) }

    around do |example|
      ActsAsTenant.with_tenant(wedding) do
        example.run
      end
    end

    context "when the website doesn't have a custom domain configured" do
      it 'returns the correct URL for the invitation' do
        expect(invitation.url).to eq("http://www.example.com/test-wedding/site/invitation/#{invitation.id}")
      end
    end

    context 'when the website has a custom domain configured' do
      before do
        wedding.website.update!(domain: 'custom-domain.com')
      end

      it 'returns the correct URL for the invitation using the custom domain' do
        expect(invitation.url).to eq("https://custom-domain.com/invitation/#{invitation.id}")
      end
    end
  end

  describe '#title' do
    let(:wedding) { create(:wedding) }

    it 'matches the title if provided' do
      expect(build(:invitation, wedding:, name: 'Foo').title).to eq('Foo')
    end

    it 'is the name of the non-considered guests joined with & if not provided' do
      invitation = create(:invitation, wedding:, name: nil)
      [
        create(:guest, status: :confirmed, name: 'Foo', wedding:, invitation:, invitation_order: 2),
        create(:guest, status: :invited, name: 'Bar', wedding:, invitation:, invitation_order: 0),
        create(:guest, status: :considered, name: 'Baz', wedding:, invitation:, invitation_order: 4),
        create(:guest, status: :tentative, name: 'FooBar', wedding:, invitation:, invitation_order: 1),
        create(:guest, status: :declined, name: 'Buzz', wedding:, invitation:, invitation_order: 5)
      ]

      expect(invitation.reload.title).to eq('Bar & FooBar & Foo & Buzz')
    end
  end
end
