# frozen_string_literal: true

module Engine
  class TaskSerializer
    attr_reader :simulation

    delegate :wedding, to: :simulation

    def initialize(simulation_id)
      @simulation = TablesArrangement.find(simulation_id)
    end

    def call
      {
        'id' => simulation.id,
        'version' => wedding.simulation_version,
        'groups' => groups,
        'solution' => solution,
        'affinities' => affinities,
        'binds' => binds,
        'bundles' => bundles
      }
    end

    private

    def bundles
      wedding.table_types.map do |type|
        {
          'units' => type.availability,
          'capacity' => type.capacity_limits.stringify_keys!
        }
      end
    end

    def binds
      wedding.guests.where.not(invitation_id: nil)
             .group(:invitation_id)
             .having('count(*) > 1')
             .pluck('array_agg(id)')
             .map { { 'people_ids' => it } }
    end

    def affinities
      GroupAffinity.where(group_a_id: wedding.group_ids)
                   .where.not(discomfort: 1)
                   .pluck(:group_a_id, :group_b_id, :discomfort).map do |row|
        {
          'group_ids' => [row[0], row[1]],
          'discomfort' => row[2].round(1).to_s
        }
      end
    end

    def groups # rubocop:disable Metrics/CyclomaticComplexity
      guests_by_group = wedding.guests.pluck(:group_id, :id).group_by(&:first)
      ungrouped_guest_ids = guests_by_group.delete(nil)&.map(&:second) || []

      ungrouped_groups = ungrouped_guest_ids.map do |id|
        {
          'id' => SecureRandom.uuid_v4,
          'people_ids' => [id]
        }
      end
      groups = guests_by_group.map do |group_id, guests|
        {
          'id' => group_id,
          'people_ids' => guests.map(&:second)
        }
      end

      groups + ungrouped_groups
    end

    def solution
      simulation.tables.includes(:seats).map do |table|
        min, max = table.capacity.minmax
        {
          'id' => table.id,
          'capacity' => { 'min' => min, 'max' => max },
          'people_ids' => table.seats.map(&:guest_id),
          'pinned_ids' => table.seats.select(&:pinned).map(&:guest_id)
        }
      end
    end
  end
end
