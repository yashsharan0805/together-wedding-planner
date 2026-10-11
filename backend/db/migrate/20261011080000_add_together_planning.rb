# frozen_string_literal: true

class AddTogetherPlanning < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :users, :google_subject, :string
    add_index :users, :google_subject, unique: true, algorithm: :concurrently
    add_column :settings, :partner_one, :string
    add_column :settings, :partner_two, :string
    add_column :settings, :venue, :string
    add_column :settings, :currency, :string, default: 'INR', null: false
    add_column :settings, :budget, :decimal, precision: 14, scale: 2, default: 0, null: false

    create_table :wedding_events, id: :uuid do |t|
      t.references :wedding, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.date :date, null: false
      t.string :start_time
      t.string :venue
      t.text :notes
      t.integer :lock_version, default: 0, null: false
      t.timestamps
    end

    create_table :planner_vendors, id: :uuid do |t|
      t.references :wedding, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :wedding_event, type: :uuid, foreign_key: { on_delete: :nullify }
      t.string :name, null: false
      t.string :category
      t.string :contact
      t.string :status, default: 'Shortlisted', null: false
      t.text :notes
      t.integer :lock_version, default: 0, null: false
      t.timestamps
    end

    create_table :event_attendances, id: :uuid do |t|
      t.references :wedding, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :guest, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :wedding_event, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :status, default: 'invited', null: false
      t.timestamps
    end
    add_index :event_attendances, %i[guest_id wedding_event_id], unique: true

    add_reference :tasks, :wedding_event, type: :uuid, index: { algorithm: :concurrently }
    add_foreign_key :tasks, :wedding_events, on_delete: :nullify, validate: false
    validate_foreign_key :tasks, :wedding_events
    add_column :tasks, :due_date, :date
    add_column :tasks, :assignee, :string
    add_column :tasks, :priority, :string, default: 'Normal', null: false
    add_column :guests, :email, :string
    add_column :guests, :phone, :string
    add_column :guests, :side, :string, default: 'Both', null: false
    add_reference :expenses, :wedding_event, type: :uuid, index: { algorithm: :concurrently }
    add_foreign_key :expenses, :wedding_events, on_delete: :nullify, validate: false
    validate_foreign_key :expenses, :wedding_events
    add_column :expenses, :category, :string
    %i[tasks guests expenses settings].each do |table|
      add_column table, :lock_version, :integer, default: 0, null: false
    end
  end
end
