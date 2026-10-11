# frozen_string_literal: true

require 'rails_helper'
require_relative 'helpers'
require_relative '../../db/migrate/20260919162723_migrate_to_menu_option_model'

RSpec.describe MigrateToMenuOptionModel do
  include MigrationTests

  context 'when there is a single wedding' do
    let(:wedding) { create(:wedding) }

    before do
      create(:guest, name: 'Meat eater', wedding:)
        .then { Guest.sanitize_sql(['UPDATE guests SET menu_choice = 0 where id = ?', it.id]) }
        .then { ActiveRecord::Base.connection.execute(it) }

      create(:guest, name: 'Fish eater', wedding:)
        .then { Guest.sanitize_sql(['UPDATE guests SET menu_choice = 10 where id = ?', it.id]) }
        .then { ActiveRecord::Base.connection.execute(it) }

      create(:guest, name: 'Vegetables eater', wedding:)
        .then { Guest.sanitize_sql(['UPDATE guests SET menu_choice = 20 where id = ?', it.id]) }
        .then { ActiveRecord::Base.connection.execute(it) }

      create(:guest, name: 'Child menu eater', wedding:)
        .then { Guest.sanitize_sql(['UPDATE guests SET menu_choice = 30 where id = ?', it.id]) }
        .then { ActiveRecord::Base.connection.execute(it) }

      create(:guest, name: 'Undecided eater', wedding:)
        .then { Guest.sanitize_sql(['UPDATE guests SET menu_choice = NULL where id = ?', it.id]) }
        .then { ActiveRecord::Base.connection.execute(it) }

      redo_migration
    end

    it 'creates the default menu options and assigns each guest its corresponding option' do
      expect(wedding.menu_options.count).to eq(4)

      expect(wedding.guests.where(name: 'Meat eater').sole.menu_option.name).to eq('meat')
      expect(wedding.guests.where(name: 'Fish eater').sole.menu_option.name).to eq('fish')
      expect(wedding.guests.where(name: 'Vegetables eater').sole.menu_option.name).to eq('vegetarian')
      expect(wedding.guests.where(name: 'Child menu eater').sole.menu_option.name).to eq('child')
      expect(wedding.guests.where(name: 'Undecided eater').sole.menu_option).to be_nil
    end
  end

  context 'when there are multiple weddings' do
    before do
      create_list(:wedding, 3)
      redo_migration
    end

    it 'creates the default options for each one of them' do
      expect(MenuOption.group(:name).count).to eq('child' => 3, 'fish' => 3, 'vegetarian' => 3, 'meat' => 3)
    end
  end
end
