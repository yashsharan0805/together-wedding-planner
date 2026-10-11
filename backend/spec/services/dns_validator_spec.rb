# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(DNSValidator) do
  let(:dns) { instance_double(Resolv::DNS, getresources: records) }

  before do
    allow(Resolv::DNS).to receive(:open).and_yield(dns)
  end

  context 'when there is no CNAME record' do
    let(:records) { [] }

    it 'raises an error' do
      expect { described_class.new('foo.com').call }.to raise_error(DNSValidator::MissingRecordError)
    end
  end

  context 'when there is a CNAME record aiming at the HOST' do
    let(:records) do
      [
        Resolv::DNS::Resource::IN::CNAME.new('www.example.com') # included in config.hosts
      ]
    end

    it 'does not raise an error' do
      expect { described_class.new('foo.com').call }.not_to raise_error
    end
  end

  context 'when there is a CNAME record aiming somewhere else' do
    let(:records) do
      [
        Resolv::DNS::Resource::IN::CNAME.new('foo.bar') # included in config.hosts
      ]
    end

    it 'raises an error' do
      expect { described_class.new('foo.com').call }.to raise_error(DNSValidator::MissingRecordError)
    end
  end
end
