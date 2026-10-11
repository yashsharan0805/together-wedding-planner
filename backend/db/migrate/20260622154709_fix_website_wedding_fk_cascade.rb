# frozen_string_literal: true

class FixWebsiteWeddingFkCascade < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :websites, :weddings
    add_foreign_key :websites, :weddings, on_delete: :cascade
  end
end
