# frozen_string_literal: true

class Page
  include ActiveModel::Model

  ATTRIBUTES = %i[slug title subtitle content title_font_family].freeze

  attr_accessor(*ATTRIBUTES)

  validates :title, presence: true
  validates :slug,
            format: { with: %r{\A(?:[a-z0-9]+(?:-[a-z0-9]+)*(?:/[a-z0-9]+(?:-[a-z0-9]+)*)*)?\z} },
            exclusion: { in: ['invitation', :invitation, nil] }
  validates :title_font_family, inclusion: { in: FONTS_AVAILABLE }, presence: true

  def initialize(hash = {})
    hash ||= {}
    hash = hash.with_indifferent_access
    ATTRIBUTES.each { instance_variable_set("@#{it}", hash[it]) }
  end

  def type
    :page
  end

  def attributes
    ATTRIBUTES.index_with { public_send(it) }
  end

  def ==(other)
    other.is_a?(self.class) && other.attributes == attributes
  end

  def cast(value)
    value.is_a?(Page) ? value : Page.new(value)
  end

  def serialize(model_list)
    model_list.attributes.to_json
  end

  def deserialize(db_value)
    Page.new(JSON.parse(db_value))
  end

  def changed_in_place?(raw_old_value, new_value)
    deserialize(raw_old_value) != new_value
  end
end
