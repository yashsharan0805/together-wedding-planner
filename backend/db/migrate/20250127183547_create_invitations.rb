class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations, id: :uuid do |t|
      t.references :wedding, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.timestamps
    end

    add_reference :guests, :invitation, foreign_key: true, type: :uuid
  end
end
