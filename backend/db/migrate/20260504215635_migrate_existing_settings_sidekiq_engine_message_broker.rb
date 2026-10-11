class MigrateExistingSettingsSidekiqEngineMessageBroker < ActiveRecord::Migration[8.1]
  def up
    Settings.unscoped.in_batches.update_all(engine_message_broker: :sidekiq)
  end

  def down
    Settings.unscoped.in_batches.update_all(engine_message_broker: :solid_queue)
  end
end
