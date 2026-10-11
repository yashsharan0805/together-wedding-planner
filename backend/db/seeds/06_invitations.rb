# frozen_string_literal: true

Group.includes(:guests).find_each do |group|
  guests = group.guests.potential.to_a

  while guests.any?
    invitation = Invitation.create!
    invitation.update!(name: "#{Faker::Hobby.activity} club") if rand < 0.3

    guests.shift(rand(1..3)).each_with_index do |guest, invitation_order|
      guest.update!(invitation:, invitation_order:)
    end
    guests.shift(1) if rand < 0.3 # Leave a percentage of guests without an invitation

  end
end

# TODO: Clean up invitations with no guests
