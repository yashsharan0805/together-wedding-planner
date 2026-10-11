# frozen_string_literal: true

class MigrateToMenuOptionModel < ActiveRecord::Migration[8.1]
  ORIGINAL_MAPPING = {
    'meat' => 0,
    'fish' => 10,
    'vegetarian' => 20,
    'child' => 30
  }.freeze

  DEFAULT_OPTIONS = Guest::DEFAULT_MENU_OPTIONS

  def up
    menu_option_attributes = []

    Wedding.pluck(:id).map do |wedding_id|
      menu_option_attributes += DEFAULT_OPTIONS.map do |option|
        { wedding_id:, name: option, i18n_key: option }
      end
    end

    MenuOption.insert_all(menu_option_attributes)

    Wedding.find_each do |wedding|
      mapping = wedding.menu_options.pluck(:i18n_key, :id).to_h

      DEFAULT_OPTIONS.each do |menu_option|
        wedding.guests.where(menu_choice: ORIGINAL_MAPPING[menu_option]).update_all(menu_option_id: mapping[menu_option])
      end
    end
  end

  def down
    # Menu options cannot be created via UI yet, so we're guaranteed all menu options that
    # exist have been created through this migration.
    MenuOption.delete_all
  end
end
