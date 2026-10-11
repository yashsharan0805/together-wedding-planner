# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

class LibreCaptcha
  def id
    HTTParty.post('http://libre-captcha:8888/v2/captcha',
                  body: {
                    input_type: 'text',
                    level: :hard,
                    media: 'image/png',
                    size: '350x100'
                  }.to_json).then { |raw| JSON.parse(raw)['id'] }
  end

  def valid?(id:, answer:)
    HTTParty.post('http://libre-captcha:8888/v2/answer',
                  body: { id:, answer: }.to_json).then { |raw| JSON.parse(raw)['result'] == 'True' }
  end
end
