# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class SerializableGroup < JSONAPI::Serializable::Resource
  type 'group'

  attributes :name, :icon

  has_many :children

  attribute :guest_count do
    @object.guests.count
  end
end
