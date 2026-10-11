class AddGuestsDigestColumnToTablesArrangements < ActiveRecord::Migration[8.0]
  def change
    add_column :tables_arrangements, :digest, :uuid, null: false, default: 'gen_random_uuid()'
  end
end
