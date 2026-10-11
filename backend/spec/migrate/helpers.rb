# frozen_string_literal: true

# Expects described_class to be the migration class under test
module MigrationTests
  def redo_migration
    instance = described_class.new

    instance.down
    instance.up
  end
end
