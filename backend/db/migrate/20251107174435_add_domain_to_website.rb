# frozen_string_literal: true

class AddDomainToWebsite < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      change_table :websites, bulk: true do |t|
        t.string :domain
        t.index Arel.sql('lower(domain)'), unique: true, name: 'uindex_websites_on_lower_domain'
      end
    end
  end

  def down
    remove_column :websites, :domain, :string
  end
end
