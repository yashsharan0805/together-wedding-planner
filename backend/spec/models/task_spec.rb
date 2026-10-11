# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task do
  let_it_be(:wedding) { create(:wedding) }
  let(:task) { create(:task) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end
end
