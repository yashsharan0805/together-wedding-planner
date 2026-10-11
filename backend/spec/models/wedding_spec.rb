# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wedding do
  let(:wedding) { create(:wedding) }

  describe 'validations' do
    subject { build(:wedding) }

    describe 'slug' do
      it { is_expected.to allow_value('foo').for(:slug) }
      it { is_expected.to allow_value('foo-bar').for(:slug) }
      it { is_expected.to allow_value('foo-123').for(:slug) }
      it { is_expected.to allow_value('foo-123-').for(:slug) }
      it { is_expected.to allow_value('foo--123').for(:slug) }

      it { is_expected.not_to allow_value('Foo').for(:slug) }
      it { is_expected.not_to allow_value('/foo').for(:slug) }
      it { is_expected.not_to allow_value('foo/123').for(:slug) }
      it { is_expected.not_to allow_value('foo_123').for(:slug) }
      it { is_expected.not_to allow_value('foo/').for(:slug) }

      # Reserved words for nginx and routing
      it { is_expected.not_to allow_value('jobs').for(:slug) }
      it { is_expected.not_to allow_value('letter_opener').for(:slug) }
      it { is_expected.not_to allow_value('captcha').for(:slug) }
      it { is_expected.not_to allow_value('api').for(:slug) }
      it { is_expected.not_to allow_value('system').for(:slug) }
      it { is_expected.not_to allow_value('sidekiq').for(:slug) }

      it { is_expected.to allow_value('job').for(:slug) }
      it { is_expected.to allow_value('captchas').for(:slug) }
      it { is_expected.to allow_value('apis').for(:slug) }
    end
  end

  describe 'DB constraints' do
    it { expect { wedding.update!(deletion_token: :foo) }.to raise_error(ActiveRecord::CheckViolation) }
    it { expect { wedding.update!(deletion_token_expires_at: Time.zone.now) }.to raise_error(ActiveRecord::CheckViolation) }
  end

  describe 'callbacks' do
    it 'creates an empty website upon creation', :aggregate_failures do
      website = create(:wedding).website

      expect(website).to be_a(Website)
      expect(website.version).to eq('v2.0')
      expect(website.pages.count).to eq(1)
      expect(website.pages.first.slug).to eq('')
      expect(website.pages.first.title).to be_nil
      expect(website.pages.first.content).to be_nil
    end

    it 'creates a settings object upon creation' do
      expect(create(:wedding).settings).to be_a(Settings)
    end

    it 'creates default menu options upon creation' do
      wedding = create(:wedding)

      expect(wedding.menu_options.pluck(:i18n_key)).to contain_exactly('fish', 'meat', 'child', 'vegetarian')
      expect(wedding.menu_options.pluck(:name)).to contain_exactly('fish', 'meat', 'child', 'vegetarian')
    end
  end

  describe '#needs_optimization!' do
    before do
      allow(WeddingPlanner.redis).to receive(:incr)
      allow(TaskProcessingJob).to receive(:perform_async)
      allow(Engine::TaskSerializer).to receive(:new).and_return(
        instance_double(Engine::TaskSerializer, call: { foo: :bar })
      )
    end

    it 'increments the version of the simulation using the wedding id' do
      wedding.needs_optimization!

      expect(WeddingPlanner.redis).to have_received(:incr).with("wedding/simulations/version/#{wedding.id}")
      expect(TaskProcessingJob).not_to have_received(:perform_async)
    end

    it 'sends a message to Sidekiq' do
      wedding.tables_arrangements.create!(system: true)

      wedding.needs_optimization!
      expect(WeddingPlanner.redis).to have_received(:incr).with("wedding/simulations/version/#{wedding.id}")
      expect(TaskProcessingJob).to have_received(:perform_async).with({ foo: :bar }.to_json)
    end
  end

  describe '#simulation_version' do
    context 'when the key is not stored in Redis yet' do
      before do
        allow(WeddingPlanner.redis).to receive(:get).with("wedding/simulations/version/#{wedding.id}").and_return(nil)
      end

      it { expect(wedding.simulation_version).to be_zero }
    end

    context 'when the key is stored in Redis' do
      before do
        allow(WeddingPlanner.redis).to receive(:get).with("wedding/simulations/version/#{wedding.id}").and_return('45')
      end

      it { expect(wedding.simulation_version).to eq(45) }
    end
  end

  describe '.simulation_version_key' do
    it { expect(described_class.simulation_version_key('123-abc')).to eq('wedding/simulations/version/123-abc') }
  end

  describe '#empty!' do
    it 'removes all guests, groups, and invitations' do
      group = create(:group, wedding:)
      invitation = create(:invitation, wedding:)
      create(:guest, group:, wedding:, invitation:)

      expect { wedding.empty! }
        .to change { wedding.guests.count }.from(1).to(0)
        .and change { wedding.groups.count }.from(1).to(0)
        .and change { wedding.invitations.count }.from(1).to(0)
    end
  end

  describe '#generate_deletion_token!' do
    it 'sets a random token and an expiration time of 1h', :aggregate_failures do
      expect { wedding.generate_deletion_token! }
        .to change(wedding, :deletion_token).from(nil).to(kind_of(String))
        .and change(wedding, :deletion_token_expires_at).from(nil).to(kind_of(ActiveSupport::TimeWithZone))

      expect(wedding.deletion_token.length).to eq(60)
      expect(wedding.deletion_token_expires_at).to be_within(1.second).of(1.hour.from_now)
    end
  end
end
