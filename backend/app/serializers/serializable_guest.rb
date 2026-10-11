# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class SerializableGuest < JSONAPI::Serializable::Resource
  type 'guest'

  attributes :id, :status

  attribute :name do
    @object.name
  end

  attribute :status do
    @object.status.capitalize
  end
end
