# frozen_string_literal: true

TableType.insert_all!(
  [
    { capacity: 8..10, availability: nil },
    { capacity: 10..12, availability: 3 },
    { capacity: 14..16, availability: 1 }
  ]
)
