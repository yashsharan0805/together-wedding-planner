# frozen_string_literal: true

class AddLanguageToUsersTable < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :language, :string
    add_check_constraint :users, 'language IS NULL OR length(language) = 2', name: 'iso639_1_length_language'
  end
end
