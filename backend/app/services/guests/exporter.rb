# frozen_string_literal: true

module Guests
  class Exporter
    def initialize(wedding:)
      @wedding = wedding
    end

    def call
      ActsAsTenant.with_tenant(@wedding) do
        CSV.generate do |csv|
          csv << headers
          guests.pluck(*columns).each { csv << it }
        end
      end
    end

    private

    def headers
      ['Name', 'Group', 'Status', 'Menu choice', 'Menu restrictions', 'Special requests']
        .tap { it << 'Needs bus' if bus_management? }
    end

    def columns
      [:name, 'groups.name', :status, 'menu_options.name', :menu_restrictions, :special_requests]
        .tap { it << :needs_bus if bus_management? }
    end

    def bus_management?
      @wedding.settings.bus_management?
    end

    def guests
      @wedding.guests.includes(:group)
              .left_joins(:group)
              .left_joins(:menu_option)
              .order('groups.name' => :asc, invitation_id: :asc, name: :asc)
    end
  end
end
