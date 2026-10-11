# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class CreateGroupAffinities < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    create_table :group_affinities, if_not_exists: true do |t|
      t.references :group_a, type: :uuid, null: false, foreign_key: { to_table: :groups }
      t.references :group_b, type: :uuid, null: false, foreign_key: { to_table: :groups }
      t.float :discomfort, null: false
      t.timestamps
    end

    add_check_constraint :group_affinities, 'group_a_id != group_b_id', name: :check_distinct_groups, if_not_exists: true
    add_check_constraint :group_affinities, 'discomfort >= 0 AND discomfort <= 2', if_not_exists: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          CREATE UNIQUE INDEX CONCURRENTLY uindex_group_pair ON group_affinities (least(group_a_id, group_b_id), greatest(group_a_id, group_b_id));
        SQL
      end

      dir.down do
        remove_index :group_affinities, name: :uindex_group_pair, if_exists: true
      end
    end
  end
end
