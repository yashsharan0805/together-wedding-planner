# frozen_string_literal: true

class TaskProcessingJob
  include Sidekiq::Job

  sidekiq_options queue: 'tasks'

  def perform(_)
    # Actual implementation in the engine service
  end
end
