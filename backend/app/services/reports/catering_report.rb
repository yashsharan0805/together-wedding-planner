# frozen_string_literal: true

module Reports
  class CateringReport < Base
    add_column name: :table,
               i18n_key: 'active_record.attributes.seat.table',
               expression: 'coalesce(tables.name, tables.number::varchar)'

    add_column name: :name,
               i18n_key: 'active_record.attributes.guest.name'

    add_column name: :menu_choice,
               expression: 'menu_options.name',
               i18n_key: 'active_record.attributes.guest.menu_choice',
               transform: lambda { |value|
                 value.nil? ? nil : I18n.t("active_record.attributes.guest/menu_choice.#{value}", default: value).capitalize
               }

    add_column name: :menu_restrictions,
               i18n_key: 'active_record.attributes.guest.menu_restrictions'

    private

    def rowset
      wedding.guests
             .joins(seats: :table)
             .left_joins(:menu_option)
             .order('tables.number', 'guests.invitation_id', 'guests.name')
    end
  end
end
