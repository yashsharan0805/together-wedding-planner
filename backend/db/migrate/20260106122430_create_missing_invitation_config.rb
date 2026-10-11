class CreateMissingInvitationConfig < ActiveRecord::Migration[8.1]
  def up
    Settings.unscoped.find_each do |it|
      it.send :set_invitation_config if it.invitation_config.nil?
    end
  end

  def down
    # No-op
  end
end
