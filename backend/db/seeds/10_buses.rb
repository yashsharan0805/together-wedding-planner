# frozen_string_literal: true

Bus.insert_all(
  [
    { wedding_id: ActsAsTenant.current_tenant.id, seats: 55 },
    { wedding_id: ActsAsTenant.current_tenant.id, seats: 55 },
    { wedding_id: ActsAsTenant.current_tenant.id, seats: 30 },
    { wedding_id: ActsAsTenant.current_tenant.id, seats: 12 }
  ]
)

BusTrip.create!(name: 'Morning trip').tap do |trip|
  trip.bus_quotes.create!(company: 'City Buses', prices:  [
                            { capacity: 20, price: 150 },
                            { capacity: 40, price: 280 },
                            { capacity: 60, price: 400 }
                          ])
  trip.bus_quotes.create!(company: 'Luxury Coaches', prices:  [
                            { capacity: 16, price: 200 },
                            { capacity: 35, price: 350 },
                            { capacity: 55, price: 500 },
                            { capacity: 59, price: 550 }
                          ])
  trip.bus_quotes.create!(company: 'Average Rides', prices:  [
                            { capacity: 25, price: 130 },
                            { capacity: 50, price: 250 },
                            { capacity: 75, price: 370 }
                          ])
end
BusTrip.create!(name: 'Evening return').tap do |trip|
  trip.bus_quotes.create!(company: 'City Buses', prices: [
                            { capacity: 20, price: 160 },
                            { capacity: 40, price: 290 },
                            { capacity: 60, price: 410 }
                          ])
  trip.bus_quotes.create!(company: 'Luxury Coaches', prices: [
                            { capacity: 16, price: 210 },
                            { capacity: 35, price:  360 },
                            { capacity: 55, price:  510 },
                            { capacity: 59, price:  560 }
                          ])
  trip.bus_quotes.create!(company: 'Average Rides', prices: [
                            { capacity: 25, price: 140 },
                            { capacity: 50, price: 260 },
                            { capacity: 75, price: 380 }
                          ])
end
