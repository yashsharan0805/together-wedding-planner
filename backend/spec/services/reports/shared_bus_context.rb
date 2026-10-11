# frozen_string_literal: true

RSpec.shared_context 'when several groups have guests with different bus needs' do
  before do
    work = create(:group, wedding:, name: 'Work')
    school = create(:group, wedding:, name: 'School')
    create(:group, wedding:, name: 'Ignoreme') # No guests

    create(:guest, name: :Alice, status: :confirmed, wedding:, group: work, needs_bus: true)
    create(:guest, name: :Bob, status: :confirmed, wedding:, group: work, needs_bus: false) # Discarded by needs_bus
    create(:guest, name: :Charlie, status: :confirmed, wedding:, group: school, needs_bus: true)
    create(:guest, name: :Dave, status: :considered, wedding:, group: school, needs_bus: true) # Discarded by non-potential status
    create(:guest, name: :Erin, status: :tentative, wedding:, group: school, needs_bus: true)
    create(:guest, name: :Frank, status: :invited, wedding:, group: school, needs_bus: true)
    create(:guest, name: :Grace, status: :confirmed, wedding:, group: school, needs_bus: false) # Discarded by needs_bus
  end
end
