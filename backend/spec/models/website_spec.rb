# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Website do
  it { is_expected.to belong_to(:wedding) }

  describe 'validations' do
    subject { create(:wedding).website }

    it { is_expected.to be_valid }

    describe 'domain' do
      it { is_expected.to allow_value(nil).for(:domain) }

      it { is_expected.to allow_value('example.com').for(:domain) }
      it { is_expected.to allow_value('www.example.com').for(:domain) }
      it { is_expected.to allow_value('sub-domain.example.co.uk').for(:domain) }
      it { is_expected.to allow_value('example.io').for(:domain) }
      it { is_expected.to allow_value('xn--bcher-kva.example').for(:domain) }
      it { is_expected.to allow_value('EXAMPLE.COM').for(:domain) }

      it { is_expected.not_to allow_value('http://example.com').for(:domain) }
      it { is_expected.not_to allow_value('https://example.com').for(:domain) }
      it { is_expected.not_to allow_value('example.com/path').for(:domain) }
      it { is_expected.not_to allow_value('example..com').for(:domain) }
      it { is_expected.not_to allow_value('.example.com').for(:domain) }
      it { is_expected.not_to allow_value('example').for(:domain) }
      it { is_expected.not_to allow_value('ex ample.com').for(:domain) }
      it { is_expected.not_to allow_value('example.com:3000').for(:domain) }
      it { is_expected.not_to allow_value('256.256.256.256').for(:domain) }
      it { is_expected.not_to allow_value('ftp://example.com').for(:domain) }
      it { is_expected.not_to allow_value(' ').for(:domain) }
      it { is_expected.not_to allow_value('').for(:domain) }
      it { is_expected.not_to allow_value(45).for(:domain) }

      it { is_expected.to validate_uniqueness_of(:domain).case_insensitive }
    end

    describe 'pages' do
      it { is_expected.not_to allow_value([]).for(:pages) }

      it 'does not allow duplicated slugs' do
        is_expected.not_to allow_value(
          [
            { slug: '', title: 'Home' },
            { slug: 'transport', title: 'Transport', content: 'By train or plane' },
            { slug: 'transport', title: 'Another transport', content: 'On foot or spaceship' }
          ]
        ).for(:pages)
      end

      it 'does not allow duplicated slugs (ignore case)' do
        is_expected.not_to allow_value(
          [
            { slug: '', title: 'Home' },
            { slug: 'transport', title: 'Transport', content: 'By train or plane' },
            { slug: 'Transport', title: 'Another transport', content: 'On foot or spaceship' }
          ]
        ).for(:pages)
      end

      it 'requires one of the pages to have empty slug (and be the root)' do
        is_expected.not_to allow_value(
          [
            { slug: 'Transport', title: 'Another transport', content: 'On foot or spaceship' }
          ]
        ).for(:pages)
      end
    end

    describe 'version' do
      it { is_expected.to validate_inclusion_of(:version).in_array(Website::KNOWN_VERSIONS) }
      it { is_expected.to validate_presence_of(:version) }
    end

    describe 'wedding_id' do
      it { is_expected.to validate_uniqueness_of(:wedding_id).case_insensitive }
    end
  end
end
