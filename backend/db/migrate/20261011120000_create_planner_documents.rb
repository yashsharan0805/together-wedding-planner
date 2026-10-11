# frozen_string_literal: true

class CreatePlannerDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :planner_documents, id: :uuid do |t|
      t.references :wedding, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :task, null: true, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :planner_vendor, null: true, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :uploaded_by, null: false, type: :uuid, foreign_key: { to_table: :users }
      t.string :file_name, null: false
      t.string :content_type, null: false
      t.integer :byte_size, null: false
      t.binary :data, null: false
      t.timestamps
    end
    add_check_constraint :planner_documents,
                         '(task_id IS NOT NULL)::integer + (planner_vendor_id IS NOT NULL)::integer = 1',
                         name: 'planner_documents_one_parent'
    add_check_constraint :planner_documents,
                         'byte_size > 0 AND byte_size <= 3145728 AND octet_length(data) = byte_size',
                         name: 'planner_documents_valid_size'
  end
end
