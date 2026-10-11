# frozen_string_literal: true

class BaseUseCase
  attr_reader :errors

  def initialize
    @errors = []
  end

  def call
    raise 'Calls to use case must be wrapped by ActsAsTenant context' unless wedding

    ActiveRecord::Base.transaction do
      private_call
    end
  end

  private

  def wedding
    ActsAsTenant.current_tenant
  end
end
