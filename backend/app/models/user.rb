# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default("")
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  google_subject         :string
#  language               :string
#  last_sign_in_at        :datetime
#  locked_at              :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  superadmin             :boolean          default(FALSE), not null
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_google_subject        (google_subject) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#  index_users_on_wedding_id            (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable,
         :recoverable, :validatable, :confirmable, :lockable

  has_many :applications, class_name: 'Doorkeeper::Application', dependent: :delete_all, as: :owner
  has_many :memberships, dependent: :delete_all
  has_many :weddings, through: :memberships

  validates :language, length: { is: 2, allow_nil: true }

  self.implicit_order_column = :created_at
  self.ignored_columns += [:wedding_id]

  class << self
    def reset_password_frontend_url(slug:, reset_password_token:)
      protocol = Rails.env.production? ? 'https' : 'http'

      "#{protocol}://#{Rails.application.routes.default_url_options[:host]}/#{slug}/" \
        "reset-password?reset_password_token=#{reset_password_token}"
    end
  end

  # https://github.com/heartcombo/devise/issues/5858
  def update_tracked_fields(_request)
    self.last_sign_in_at = Time.zone.now
  end

  def default_wedding
    weddings.first
  end
end
