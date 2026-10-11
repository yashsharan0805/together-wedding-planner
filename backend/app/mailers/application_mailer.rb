# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  class << self
    private

    def default_from
      MailConfig.new.default_from
    end
  end

  default from: default_from
  layout 'mailer'
end
