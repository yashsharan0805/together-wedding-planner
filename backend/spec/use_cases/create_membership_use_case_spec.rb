# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateMembershipUseCase do
  describe '#call' do
    let(:email) { 'foo@bar.com' }
    let(:use_case) { described_class.new(email:) }
    let(:wedding) { create(:wedding) }

    around { |example| ActsAsTenant.with_tenant(wedding) { example.run } }

    def validate_unconfirmed_membership(membership)
      expect(membership.confirmed_at).to be_nil
      expect(membership.confirmation_token).not_to be_nil
      expect(membership.confirmation_token_expires_at).to be_within(1.second).of(1.week.from_now)
    end

    RSpec.shared_examples('failed membership creation') do |message|
      it { expect { use_case.call }.not_to send_email }
      it { expect { use_case.call }.to not_change(User, :count) }

      it "fails with the validation errors as the use case's" do
        expect(use_case.call).to be_falsey
        expect(use_case.errors).to contain_exactly(message)
      end
    end

    context 'when the user does not exist' do
      it 'creates a new unconfirmed user and unconfirmed membership', :aggregate_failures do
        expect { use_case.call }.to change(User, :count).by(1).and change(Membership, :count).by(1)

        user = User.find_by(email:)
        expect(user.confirmed_at).to be_nil
        expect(user.confirmation_token).not_to be_nil

        validate_unconfirmed_membership(Membership.find_by(user:, wedding:))
      end

      it { expect { use_case.call }.to send_email(to: 'foo@bar.com', subject: 'Confirmation instructions') }
      it { expect { use_case.call }.to send_email(to: 'foo@bar.com', subject: 'Join the wedding organization team!') }

      context 'when there are validation erros creating the user' do
        let(:email) { 'foo@@bar.com' }

        it_behaves_like 'failed membership creation', 'Email is invalid'
      end
    end

    context 'when the user exists' do
      let!(:user) { create(:user, email:, wedding: create(:wedding)) }

      context 'when they are already a member of the wedding' do
        it_behaves_like 'failed membership creation', 'User is already a member'
      end

      context 'when they are not members of this wedding yet' do
        before do
          user.memberships.delete_all
        end

        it { expect { use_case.call }.to send_email(to: 'foo@bar.com', subject: 'Join the wedding organization team!') }
        it { expect { use_case.call }.to not_change(User, :count) }

        it 'creates an unconfirmed membership' do
          use_case.call
          validate_unconfirmed_membership(Membership.find_by!(user:, wedding:))
        end
      end
    end
  end
end
