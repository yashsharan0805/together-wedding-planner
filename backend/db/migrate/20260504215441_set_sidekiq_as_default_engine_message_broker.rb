class SetSidekiqAsDefaultEngineMessageBroker < ActiveRecord::Migration[8.1]
  def change
    change_column_default :settings, :engine_message_broker, from: :solid_queue, to: :sidekiq
  end
end
