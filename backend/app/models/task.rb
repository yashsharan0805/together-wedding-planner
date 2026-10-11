# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id               :uuid             not null, primary key
#  assignee         :string
#  completed_at     :datetime
#  due_date         :date
#  lock_version     :integer          default(0), not null
#  priority         :string           default("Normal"), not null
#  title            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  wedding_event_id :uuid
#  wedding_id       :uuid             not null
#
# Indexes
#
#  index_tasks_on_wedding_event_id  (wedding_event_id)
#  index_tasks_on_wedding_id        (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (wedding_event_id => wedding_events.id) ON DELETE => nullify
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class Task < ApplicationRecord
  acts_as_tenant :wedding
  belongs_to :wedding_event, optional: true
  has_many :documents, class_name: 'PlannerDocument', dependent: :delete_all
  validates :title, presence: true

  self.implicit_order_column = :created_at

  def complete!
    update!(completed_at: Time.zone.now) if completed_at.nil?
  end

  def uncomplete!
    update(completed_at: nil)
  end
end
