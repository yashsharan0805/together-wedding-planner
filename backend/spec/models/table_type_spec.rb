# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_examples'

RSpec.describe TableType do
  describe 'validations' do
    describe 'capacity' do
      it { is_expected.to validate_presence_of(:capacity) }

      it_behaves_like 'a range representing table capacity'
    end

    describe 'availability' do
      it { is_expected.to validate_numericality_of(:availability).is_greater_than(0).allow_nil }
    end
  end
end
