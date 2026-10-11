# frozen_string_literal: true

class GenerateSystemSimulationsJob < ApplicationJob
  def perform
    ActsAsTenant.without_tenant do
      Wedding.where.not(id: TablesArrangement.where(system: true).select(:wedding_id)).find_each do |wedding|
        wedding.tables_arrangements.create!(system: true)
        wedding.needs_optimization!
      end
    end
  end
end
