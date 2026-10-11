class BackfillEditableColumn < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    ActsAsTenant.without_tenant do
      TablesArrangement.in_batches.update_all(Arel.sql("editable = ancestor_id IS NOT NULL"))
    end
  end

  def down
    ActsAsTenant.without_tenant do
      TablesArrangement.in_batches.update_all(editable: false)
    end
  end
end
