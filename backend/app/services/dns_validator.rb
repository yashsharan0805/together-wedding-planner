# frozen_string_literal: true

class DNSValidator
  class MissingRecordError < StandardError; end

  def initialize(domain)
    @domain = domain
  end

  def call
    expected = Rails.application.routes.default_url_options[:host]
    cnames = Resolv::DNS.open { it.getresources(@domain, Resolv::DNS::Resource::IN::CNAME) }
                        .map { it.name.to_s }

    raise MissingRecordError, "No CNAME records found for domain #{@domain}" if cnames.empty?
    raise MissingRecordError, "Unexpected CNAME found: #{cnames.first}, expected: #{expected}" if cnames != [expected]

    nil
  end
end
