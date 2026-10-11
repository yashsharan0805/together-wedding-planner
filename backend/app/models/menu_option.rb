# frozen_string_literal: true

# == Schema Information
#
# Table name: menu_options
#
#  id         :uuid             not null, primary key
#  i18n_key   :string
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  wedding_id :uuid             not null
#
# Indexes
#
#  index_menu_options_on_wedding_id  (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class MenuOption < ApplicationRecord
  acts_as_tenant :wedding

  has_many :guests, dependent: :nullify

  validates :name, presence: true

  self.implicit_order_column = :created_at
end
