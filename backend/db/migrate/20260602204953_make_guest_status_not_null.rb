class MakeGuestStatusNotNull < ActiveRecord::Migration[8.1]
  def up
    # There shouldn't be any, just in case to avoid unexpected scenarios
    Guest.unscoped.where(status: :nil).update_all(status: :considered) # Default
    change_column_null(:guests, :status, false)
  end

  def down
    change_column_null(:guests, :status, true)
  end
end
