# frozen_string_literal: true

class MakeGroupAffinitiesFkCascadeDelete < ActiveRecord::Migration[8.1]
  def change
    %i[group_a_id group_b_id].each do |column|
      remove_foreign_key :group_affinities, to_table: :groups, column:, if_exists: true

      add_foreign_key :group_affinities,
                      :groups,
                      column:,
                      name: "fk_rails_#{column}",
                      on_delete: :cascade,
                      if_not_exists: true
    end
  end
end
