# frozen_string_literal: true

module Reports
  class BusGroupsReport < Base
    add_column name: :group,
               i18n_key: 'active_record.attributes.guest.group',
               expression: 'groups.name'
    add_column name: :guest_count,
               i18n_key: 'reports.bus_groups.guest_count',
               expression: 'count(*)'

    private

    def rowset
      wedding.guests.potential.where(needs_bus: true)
             .joins(:group)
             .group('groups.id', 'groups.name')
             .order('guest_count DESC', 'groups.name ASC')
    end
  end
end
