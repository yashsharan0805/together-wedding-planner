class AddPagesToWebsite < ActiveRecord::Migration[8.1]
  def change
    add_column :websites, :version, :string, null: false, default: "v2.0"
    add_column :websites, :pages, :jsonb, null: false, default: '{}', array: true
  end
end
