# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvitationConfig do
  let(:wedding) { create(:wedding) }
  let(:settings) { wedding.settings }

  let(:config) do
    described_class.new(
      qr_position: [670, 445],
      qr_color: '#343434',
      qr_fill_color: nil,
      qr_size_px: 250,
      text_position: [200, 450],
      text_font_family: 'Arial',
      text_color: '#4E342E',
      text_font_size: 35,
      text_font_weight: 500,
      text_align: :center
    )
  end

  describe 'validations' do
    subject { build(:invitation_config, settings:) }

    it { is_expected.to validate_uniqueness_of(:settings_id).case_insensitive }

    %i[qr_position text_position].each do |field|
      it { is_expected.to allow_value([0, 0]).for(field) }
      it { is_expected.to allow_value([0, 100]).for(field) }
      it { is_expected.to allow_value([100, 0]).for(field) }
      it { is_expected.to allow_value([100, 100]).for(field) }

      it { is_expected.not_to allow_value([-1, 0]).for(field) }
      it { is_expected.not_to allow_value([0, -1]).for(field) }
      it { is_expected.not_to allow_value([-1, -1]).for(field) }
      it { is_expected.not_to allow_value(1).for(field) }
    end

    %i[qr_color qr_fill_color text_color].each do |field|
      it { is_expected.to allow_value('#012345').for(field) }
      it { is_expected.to allow_value('#ffffff').for(field) }
      it { is_expected.to allow_value('#FFFFFF').for(field) }
      it { is_expected.to allow_value('#ffFFff').for(field) }

      it { is_expected.not_to allow_value('FFFFFF').for(field) }
      it { is_expected.not_to allow_value('#FFFFFFF').for(field) }
      it { is_expected.not_to allow_value('#FFFFFG').for(field) }
      it { is_expected.not_to allow_value('helloworld').for(field) }
      it { is_expected.not_to allow_value('.').for(field) }
      it { is_expected.not_to allow_value(0).for(field) }
    end

    describe 'text_font_weight' do
      it { is_expected.to validate_presence_of(:text_font_weight) }

      [100, 200, 300, 400, 500, 600, 700, 800, 900].each do |valid_value|
        it { is_expected.to allow_value(valid_value).for(:text_font_weight) }
      end

      [0, -1, 1000, 123.45, 550].each do |invalid_value|
        it { is_expected.not_to allow_value(invalid_value).for(:text_font_weight) }
      end
    end

    it { is_expected.to validate_presence_of(:qr_color) }
    it { is_expected.to validate_presence_of(:text_color) }
    it { is_expected.not_to validate_presence_of(:qr_fill_color) }
    it { is_expected.to allow_value(nil).for(:qr_fill_color) }

    it { is_expected.to validate_presence_of(:qr_size_px) }
    it { is_expected.to validate_numericality_of(:qr_size_px).only_integer.is_greater_than_or_equal_to(50) }

    it { is_expected.to validate_presence_of(:text_font_size) }
    it { is_expected.to validate_numericality_of(:text_font_size).only_integer.is_greater_than_or_equal_to(0) }

    it { is_expected.to validate_presence_of(:text_align) }
    it { is_expected.to validate_inclusion_of(:text_align).in_array(%w[left right center]) }

    it { is_expected.to validate_presence_of(:text_font_family) }

    it { is_expected.to validate_inclusion_of(:text_font_family).in_array(FONTS_AVAILABLE) }
  end

  describe 'callbacks' do
    it 'defines a default background on create', :aggregate_failures do
      expect(settings.invitation_config.background).to be_a ActiveStorage::Attached::One
      expect(settings.invitation_config.background.name).to eq 'background'
      expect(settings.invitation_config.background.blob.content_type).to eq 'image/jpeg'
    end
  end

  describe '#fonts_css' do
    it 'returns the font-related styles in a CSS-compatible way', :aggregate_failures do
      expect(config.fonts_css).to include 'font-size: 35px;'
      expect(config.fonts_css).to include 'font-weight: 500;'
      expect(config.fonts_css).to include 'font-family: Arial;'
      expect(config.fonts_css).to include 'color: #4E342E;'
      expect(config.fonts_css).to include 'text-align: center;'
      expect(config.fonts_css).to include 'position: absolute;'
      expect(config.fonts_css).to include 'margin: 0;'
      expect(config.fonts_css).to include 'list-style-type: none;'
      expect(config.fonts_css).to include 'left: 200px;'
      expect(config.fonts_css).to include 'top: 450px;'
    end
  end

  describe '#qr_css' do
    it 'returns the QR-code-related styles in a CSS-compatible way', :aggregate_failures do
      expect(config.qr_css).to include 'display: inline-block;'
      expect(config.qr_css).to include 'position: absolute;'
      expect(config.qr_css).to include 'width: 250px;'
      expect(config.qr_css).to include 'height: 250px;'
      expect(config.qr_css).to include 'left: 670px;'
      expect(config.qr_css).to include 'top: 445px;'
    end
  end
end
