class AddTitleToInvitation < ActiveRecord::Migration[8.1]
  def change
    add_column :invitations, :name, :string
  end
end
