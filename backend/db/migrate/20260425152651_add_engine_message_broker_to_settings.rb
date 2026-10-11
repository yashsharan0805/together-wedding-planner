class AddEngineMessageBrokerToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :engine_message_broker, :string, null: false, default: :solid_queue
  end
end
