# frozen_string_literal: true

cost_center_a = CostCenter.create!(name: 'Cost center A')
cost_center_b = CostCenter.create!(name: 'Cost center B')

Expense.create!(name: 'Photographer', amount: 3000, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 500, cost_center: cost_center_a)
  expense.payments.create!(amount: 1000, cost_center: cost_center_b)
end

Expense.create!(name: 'Country house', amount: 6000, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 1000, cost_center: cost_center_b)
  expense.payments.create!(amount: 1500, cost_center: cost_center_a)
  expense.payments.create!(amount: 1200, cost_center: cost_center_a)
  expense.payments.create!(amount: 1300,  title: 'Second installment')
  expense.payments.create!(amount: 1000,  title: 'Final payment')
end

Expense.create!(name: 'Catering', amount: 200, pricing_type: 'per_person').tap do |expense|
  expense.payments.create!(amount: 3000, cost_center: cost_center_a)
  expense.payments.create!(amount: 600,  title: 'Menu tasting fee')
end

Expense.create!(name: 'Flowers', amount: 500, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 200, cost_center: cost_center_b)
  expense.payments.create!(amount: 150,  title: 'Centerpieces payment')
end

Expense.create!(name: 'Band', amount: 1000, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 400, cost_center: cost_center_a)
end

Expense.create!(name: 'Wedding planner', amount: 2000, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 400,  title: 'Initial consultation fee')
  expense.payments.create!(amount: 500,  title: 'Planning phase payment')
  expense.payments.create!(amount: 400, cost_center: cost_center_a)
  expense.payments.create!(amount: 400, cost_center: cost_center_a)
  expense.payments.create!(amount: 300, cost_center: cost_center_b)
end

Expense.create!(name: 'Dress', amount: 1000, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 300,  title: 'Dress deposit')
  expense.payments.create!(amount: 200, cost_center: cost_center_b)
end

Expense.create!(name: 'Suit', amount: 500, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 250,  title: 'Suit deposit')
end

Expense.create!(name: 'Rings', amount: 1000, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 500,  title: 'Ring selection deposit')
  expense.payments.create!(amount: 300, cost_center: cost_center_b)
end

Expense.create!(name: 'Makeup', amount: 200, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 80,  title: 'Trial makeup session')
  expense.payments.create!(amount: 120,  title: 'Wedding day makeup')
end

Expense.create!(name: 'Hairdresser', amount: 200, pricing_type: 'fixed')

Expense.create!(name: 'Transportation', amount: 3000, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 600,  title: 'Vehicle booking deposit')
  expense.payments.create!(amount: 700,  title: 'Insurance and permits')
  expense.payments.create!(amount: 800, cost_center: cost_center_b)
  expense.payments.create!(amount: 500, cost_center: cost_center_b)
  expense.payments.create!(amount: 400,  title: 'Final service fee')
end

Expense.create!(name: 'Invitations', amount: 200, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 120,  title: 'Design and printing')
  expense.payments.create!(amount: 80, cost_center: cost_center_b)
end

Expense.create!(name: 'Cake', amount: 500, pricing_type: 'fixed').tap do |expense|
  expense.payments.create!(amount: 150,  title: 'Cake tasting deposit')
  expense.payments.create!(amount: 200, cost_center: cost_center_b)
end
