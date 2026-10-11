# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

class Numeric
  def to_currency
    Money.from_amount(self, 'EUR').format
  end
end

class Set
  def to_table
    Tables::Table.new(self)
  end


  def reject_pop(&blk)
    element = to_a.reject{blk.call(it)}.sample
    delete(element)
    element
  end
end

class ActiveStorage::Attached::One
  def to_data_url
    "data:#{content_type};base64,#{blob.open{Base64.strict_encode64(it.read)}}"
  end

  def css_dimensions
    metadata.slice(:width, :height).map{|k, v| "#{k}: #{v}px;"}.join(" ")
  end
end

class ActiveRecord::Point
  def css_position
    "left: #{x.to_i}px; top: #{y.to_i}px;"
  end
end