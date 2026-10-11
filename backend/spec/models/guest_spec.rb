# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Guest do
  describe 'validations' do
    subject(:guest) { build(:guest) }

    it { is_expected.to validate_presence_of(:name) }

    it do
      expect(guest).to define_enum_for(:status).with_values(
        considered: 0,
        invited: 10,
        confirmed: 20,
        declined: 30,
        tentative: 40
      )
    end

    it 'disallows two guests with the same order in the same invitation' do
      wedding = create(:wedding)
      invitation = create(:invitation, wedding:)

      create(:guest, invitation:, wedding:, invitation_order: 3)
      expect(build(:guest, invitation:, wedding:, invitation_order: 3)).not_to be_valid
      expect(build(:guest, invitation:, wedding:, invitation_order: 4)).to be_valid
    end
  end

  it { is_expected.to belong_to(:group).optional }

  describe 'callbacks' do
    let(:wedding) { create(:wedding) }
    let(:invitation) { create(:invitation, wedding:) }

    context 'when an invitation is assigned' do
      it 'preserves the order assigned if both an invitation and an order are provided' do
        guest = create(:guest, wedding:, invitation:, invitation_order: 4)
        expect(guest.reload.invitation_order).to eq(4)
      end

      it 'assigns a random order to be keep consistency between reloads' do
        guest = create(:guest, wedding:, invitation:)
        expect(guest.reload.invitation_order).to be_between(0, (2**31) - 1).inclusive
      end

      it 'does not assign an order if the invitation is not provided' do
        guest = create(:guest, wedding:, invitation: nil)
        expect(guest.reload.invitation_order).to be_nil
      end
    end

    context 'when an invitation is deassigned' do
      it 'nullifies the invitation order' do
        guest = create(:guest, wedding:, invitation:, invitation_order: 1234)
        guest.update(invitation: nil)
        expect(guest.invitation_order).to be_nil
        expect(guest.reload.invitation_order).to be_nil
      end
    end

    describe 'status changes' do
      before do
        allow(wedding).to receive(:needs_optimization!)
      end

      context 'when a guest is created with potential status' do
        it 'triggers an optimization of the system simulation' do
          create(:guest, wedding:, status: :invited)

          expect(wedding).to have_received(:needs_optimization!)
        end
      end

      context 'when a guest is created with non-potential status' do
        it 'does not trigger an optimization of the system simulation' do
          create(:guest, wedding:, status: :considered)

          expect(wedding).not_to have_received(:needs_optimization!)
        end
      end

      context 'when a guest status changes from potential to non-potential' do
        it 'triggers an optimization of the system simulation' do
          create(:guest, wedding:, status: :confirmed).update!(status: :declined)

          expect(wedding).to have_received(:needs_optimization!).twice # creation and update
        end
      end

      context 'when a guest status changes from non-potential to potential' do
        it 'triggers an optimization of the system simulation' do
          create(:guest, wedding:, status: :considered).update!(status: :invited)

          expect(wedding).to have_received(:needs_optimization!)
        end
      end

      context 'when a guest status changes between potential statuses' do
        it 'does not trigger an optimization of the system simulation' do
          create(:guest, wedding:, status: :invited).update!(status: :confirmed)

          expect(wedding).to have_received(:needs_optimization!).once # just on creation, not on update
        end
      end

      context 'when a guest status changes between non-potential statuses' do
        it 'does not trigger an optimization of the system simulation' do
          create(:guest, wedding:, status: :considered).update!(status: :declined)

          expect(wedding).not_to have_received(:needs_optimization!)
        end
      end

      context 'when a guest in potential status is destroyed' do
        it 'triggers an optimization of the system simulation' do
          create(:guest, wedding:, status: :confirmed).destroy

          expect(wedding).to have_received(:needs_optimization!).twice # creation and deletion
        end
      end

      context 'when a guest in non-potential status is destroyed' do
        it 'triggers an optimization of the system simulation' do
          create(:guest, wedding:, status: :considered).destroy

          expect(wedding).not_to have_received(:needs_optimization!)
        end
      end

      context 'when a potential guest is assigned to a group' do
        it 'triggers an optimization of the system simulation' do
          create(:guest, wedding:, status: :invited).update!(group: create(:group, wedding:))

          expect(wedding).to have_received(:needs_optimization!).twice # creation and group assignment
        end
      end

      context 'when a non-potential guest is assigned to a group' do
        it 'does not trigger an optimization of the system simulation' do
          create(:guest, wedding:, status: :considered).update!(group: create(:group, wedding:))

          expect(wedding).not_to have_received(:needs_optimization!)
        end
      end

      context 'when a potential guest changes groups' do
        it 'triggers an optimization of the system simulation' do
          create(:guest, wedding:, status: :invited)
            .tap { it.update!(group: create(:group, wedding:)) }
            .tap { it.update!(group: create(:group, wedding:)) }

          expect(wedding).to have_received(:needs_optimization!).thrice # creation and 2x group assignment
        end
      end

      context 'when a non-potential guest changes groups' do
        it 'triggers an optimization of the system simulation' do
          create(:guest, wedding:, status: :considered)
            .tap { it.update!(group: create(:group, wedding:)) }
            .tap { it.update!(group: create(:group, wedding:)) }

          expect(wedding).not_to have_received(:needs_optimization!)
        end
      end
    end
  end

  describe 'scopes' do
    describe '.potential' do
      it 'returns guests that are not declined or considered' do
        wedding = create(:wedding)
        _declined_guest = create(:guest, status: :declined, wedding:)
        _considered_guest = create(:guest, status: :considered, wedding:)
        invited_guest = create(:guest, status: :invited, wedding:)
        confirmed_guest = create(:guest, status: :confirmed, wedding:)
        tentative_guest = create(:guest, status: :tentative, wedding:)

        expect(described_class.potential).to contain_exactly(invited_guest, confirmed_guest, tentative_guest)
      end
    end
  end
end
