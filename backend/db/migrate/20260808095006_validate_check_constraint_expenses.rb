# frozen_string_literal: true

class ValidateCheckConstraintExpenses < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    validate_check_constraint :expenses, name: :check_positive_amount
  end
end
