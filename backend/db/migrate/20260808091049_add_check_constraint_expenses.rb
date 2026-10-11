# frozen_string_literal: true

class AddCheckConstraintExpenses < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :expenses, 'amount > 0', name: :check_positive_amount, if_not_exists: true, validate: false
  end
end
