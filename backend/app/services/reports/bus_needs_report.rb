# frozen_string_literal: true

module Reports
  class BusNeedsReport < Base
    add_column name: :name,
               i18n_key: 'active_record.attributes.guest.name',
               expression: 'guests.name'
    add_column name: :group,
               i18n_key: 'active_record.attributes.guest.group',
               expression: 'groups.name'

    def initialize(wedding:, needs_bus:)
      super(wedding:)
      @needs_bus = needs_bus
    end

    private

    def rowset
      wedding.guests.potential
             .joins(:group)
             .where(needs_bus: @needs_bus)
             .order('groups.name ASC', 'guests.invitation_id', 'guests.name ASC')
    end
  end
end
