# frozen_string_literal: true

require 'marcel'
require 'zip'

# Small, private documents are durable in Postgres, including on ephemeral hosts.
# == Schema Information
#
# Table name: planner_documents
#
#  id                :uuid             not null, primary key
#  byte_size         :integer          not null
#  content_type      :string           not null
#  data              :binary           not null
#  file_name         :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  planner_vendor_id :uuid
#  task_id           :uuid
#  uploaded_by_id    :uuid             not null
#  wedding_id        :uuid             not null
#
# Indexes
#
#  index_planner_documents_on_planner_vendor_id  (planner_vendor_id)
#  index_planner_documents_on_task_id            (task_id)
#  index_planner_documents_on_uploaded_by_id     (uploaded_by_id)
#  index_planner_documents_on_wedding_id         (wedding_id)
#
# Foreign Keys
#
#  fk_rails_...  (planner_vendor_id => planner_vendors.id) ON DELETE => cascade
#  fk_rails_...  (task_id => tasks.id) ON DELETE => cascade
#  fk_rails_...  (uploaded_by_id => users.id)
#  fk_rails_...  (wedding_id => weddings.id) ON DELETE => cascade
#
class PlannerDocument < ApplicationRecord
  MAX_FILE_BYTES = 3 * 1024 * 1024
  MAX_RECORD_FILES = 10
  MAX_WEDDING_BYTES = 100 * 1024 * 1024
  METADATA_FIELDS = %i[id file_name content_type byte_size created_at].freeze
  TYPES = {
    '.pdf' => 'application/pdf', '.png' => 'image/png',
    '.jpg' => 'image/jpeg', '.jpeg' => 'image/jpeg', '.webp' => 'image/webp',
    '.txt' => 'text/plain', '.csv' => 'text/csv',
    '.docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    '.pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
  }.freeze
  OFFICE_ENTRIES = { '.docx' => 'word/document.xml', '.xlsx' => 'xl/workbook.xml',
                     '.pptx' => 'ppt/presentation.xml' }.freeze

  acts_as_tenant :wedding
  belongs_to :task, optional: true
  belongs_to :planner_vendor, optional: true
  belongs_to :uploaded_by, class_name: 'User'
  validates :file_name, presence: true, length: { maximum: 200 }
  validates :byte_size, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_FILE_BYTES }
  validates :content_type, inclusion: { in: TYPES.values }
  validate :same_wedding
  validate :valid_document

  def metadata
    as_json(only: METADATA_FIELDS)
  end

  private

  def same_wedding
    parents = [task, planner_vendor].compact
    errors.add(:base, 'Choose exactly one task or vendor.') unless parents.size == 1
    errors.add(:base, 'The record must belong to this wedding.') if parents.any? { |parent| parent.wedding_id != wedding_id }
  end

  def valid_document
    return unless data_changed? || file_name_changed? || content_type_changed? || byte_size_changed?

    extension = File.extname(file_name.to_s).downcase
    valid = TYPES[extension] == content_type && data.present? && data.bytesize == byte_size
    if valid && OFFICE_ENTRIES.key?(extension)
      Zip::File.open_buffer(StringIO.new(data)) do |archive|
        # Inspect names only; never extract or decompress uploaded ZIP entries.
        valid = archive.find_entry('[Content_Types].xml').present? &&
                archive.find_entry(OFFICE_ENTRIES.fetch(extension)).present?
      end
    elsif valid && %w[.txt .csv].include?(extension)
      text = data.dup.force_encoding(Encoding::UTF_8)
      valid = text.valid_encoding? && !text.include?("\x00")
    elsif valid
      valid = Marcel::MimeType.for(StringIO.new(data)) == content_type
    end
    errors.add(:base, 'Choose a valid PDF, Office document, text, CSV, or image file (up to 3 MB).') unless valid
  rescue Zip::Error, ArgumentError
    errors.add(:base, 'The document format does not match its filename.')
  end
end
