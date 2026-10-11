# frozen_string_literal: true

class AddMenuOptionToGuest < ActiveRecord::Migration[8.1]
  def change
    add_reference :guests, :menu_option, type: :uuid, foreign_key: { on_delete: :nullify }
  end
end
