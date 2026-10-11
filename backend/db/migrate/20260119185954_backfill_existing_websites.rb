class BackfillExistingWebsites < ActiveRecord::Migration[8.1]
  def change
    Website.unscoped.in_batches.update_all(version: "v1.0")
  end
end
