# frozen_string_literal: true

# == Schema Information
#
# Table name: invitation_configs
#
#  id               :uuid             not null, primary key
#  qr_color         :string           default("#000000"), not null
#  qr_fill_color    :string
#  qr_position      :point            default(#<struct ActiveRecord::Point x=0.0, y=0.0>), not null
#  qr_size_px       :integer          default(250), not null
#  text_align       :string           default("left"), not null
#  text_color       :string           default("#000000"), not null
#  text_font_family :string           default("Arial"), not null
#  text_font_size   :integer          default(20), not null
#  text_font_weight :integer          default(400), not null
#  text_position    :point            default(#<struct ActiveRecord::Point x=0.0, y=300.0>), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  settings_id      :uuid             not null
#
# Indexes
#
#  index_invitation_configs_on_settings_id  (settings_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (settings_id => settings.id) ON DELETE => cascade
#
class InvitationConfig < ApplicationRecord
  WEIGHTS_ALLOWED = (1..9).map { it * 100 }.freeze
  ALIGNMENTS_ALLOWED = %w[left right center].freeze

  self.implicit_order_column = :created_at

  belongs_to :settings

  has_one_attached :background

  validates :qr_position, :text_position, position: true
  validates :qr_color, :text_color, :qr_size_px, :text_font_size, :text_font_weight, :text_align, :text_font_family,
            presence: true
  validates :qr_color, :text_color, :qr_fill_color, format: { with: /\A#[0-9a-fA-F]{6}\z/ }, allow_nil: true
  validates :qr_size_px, numericality: { greater_than_or_equal_to: 50, only_integer: true }
  validates :text_font_size, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :text_font_weight, inclusion: { in: WEIGHTS_ALLOWED }
  validates :text_align, inclusion: { in: ALIGNMENTS_ALLOWED }
  validates :text_font_family, inclusion: { in: FONTS_AVAILABLE }
  validates :settings_id, uniqueness: true

  after_create :set_default_background

  def fonts_available
    FONTS_AVAILABLE
  end

  def fonts_css
    css_merge(
      text_position,
      'font-size': "#{text_font_size}px",
      'font-weight': text_font_weight,
      'font-family': text_font_family,
      color: text_color,
      'text-align': text_align,
      position: :absolute,
      margin: 0,
      'list-style-type': 'none'
    )
  end

  def qr_css
    css_merge(
      qr_position,
      display: 'inline-block',
      position: :absolute,
      width: "#{qr_size_px}px",
      height: "#{qr_size_px}px"
    )
  end

  private

  def css_merge(position, properties)
    "#{properties.map { |k, v| "#{k}: #{v}" }.join('; ')};#{position.css_position}"
  end

  def set_default_background
    background.attach(io: File.open('app/assets/images/sample-background.jpg'), filename: 'background')
  end
end
