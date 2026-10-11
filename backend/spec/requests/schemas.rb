# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module Swagger
  module Schema
    ID = { # rubocop:disable Style/MutableConstant -- rswag modifies in: :path parameters
      name: 'id',
      in: :path,
      schema: {
        type: :string,
        format: :uuid
      }
    }

    GROUP = {
      name: { type: :string },
      icon: { type: :string, example: 'pi pi-crown', description: 'The CSS classes used by the icon', nullable: true },
      parent_id: { type: :string, format: :uuid, nullable: true },
      color: { type: :string, pattern: '^#(?:[0-9a-fA-F]{3}){1,2}$' }
    }.freeze

    EXPENSE = {
      name: { type: :string },
      amount: { type: :string }, # Using string to represent decimal values
      pricing_type: { type: :string, enum: Expense.pricing_types.keys },
      payments: {
        type: :array,
        items: {
          type: :object,
          required: %i[title amount],
          properties: {
            title: { type: :string },
            amount: { type: :string },
            cost_center_id: { type: :string, format: :uuid }
          }
        }
      }
    }.freeze

    TASK = {
      title: { type: :string },
      completed_at: { type: :string, format: 'date-time', nullable: true }
    }.freeze

    SLUG = { # rubocop:disable Style/MutableConstant -- rswag modifies in: :path parameters
      name: 'slug',
      in: :path,
      schema: {
        type: :string,
        pattern: '^[a-z\d-]+$'
      },
      example: :default,
      description: 'Wedding slug'
    }

    CAPTCHA = {
      captcha: {
        type: :object,
        required: %i[id answer],
        properties: {
          id: { type: :string, format: :uuid },
          answer: { type: :string }
        }
      }
    }.freeze
  end
end
