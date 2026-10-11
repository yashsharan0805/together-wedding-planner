class SaveDiscomfortFloat < ActiveRecord::Migration[8.1]
  def up
    # In the current status of the project the data volume is very low and
    # we can afford a full table rewrite.
    safety_assured do
      change_column(:tables_arrangements, :discomfort, :float)
    end
  end

  def down
    safety_assured do
      change_column(:tables_arrangements, :discomfort, :integer)
    end
  end
end
