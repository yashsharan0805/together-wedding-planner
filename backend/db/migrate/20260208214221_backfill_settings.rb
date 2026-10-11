class BackfillSettings < ActiveRecord::Migration[8.1]
  def up
    ActsAsTenant.without_tenant do
      Wedding.where.not(id: Settings.select(:wedding_id)).find_each(&:create_settings!)
    end
  end

  def down
    # no-op
  end
end
