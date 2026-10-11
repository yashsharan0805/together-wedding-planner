# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusPriceOptimizer do
  let(:prices) do
    # guests => price per bus
    {
      4 => 80,
      10 => 100,
      30 => 250,
      55 => 300
    }
  end
  let(:optimizer) { described_class.new(prices) }

  describe '#best_price' do
    it { expect { optimizer.best_price(-1) }.to raise_error ArgumentError }
    it { expect(optimizer.best_price(0)).to eq(0) }
    it { expect(optimizer.best_price(1)).to eq(80) }
    it { expect(optimizer.best_price(2)).to eq(80) }
    it { expect(optimizer.best_price(3)).to eq(80) }
    it { expect(optimizer.best_price(4)).to eq(80) }
    it { expect(optimizer.best_price(5)).to eq(100) }
    it { expect(optimizer.best_price(6)).to eq(100) }
    it { expect(optimizer.best_price(7)).to eq(100) }
    it { expect(optimizer.best_price(8)).to eq(100) }
    it { expect(optimizer.best_price(9)).to eq(100) }
    it { expect(optimizer.best_price(10)).to eq(100) }
    it { expect(optimizer.best_price(11)).to eq(180) }
    it { expect(optimizer.best_price(12)).to eq(180) }
    it { expect(optimizer.best_price(13)).to eq(180) }
    it { expect(optimizer.best_price(14)).to eq(180) }
    it { expect(optimizer.best_price(15)).to eq(200) }
    it { expect(optimizer.best_price(16)).to eq(200) }
    it { expect(optimizer.best_price(17)).to eq(200) }
    it { expect(optimizer.best_price(18)).to eq(200) }
    it { expect(optimizer.best_price(19)).to eq(200) }
    it { expect(optimizer.best_price(20)).to eq(200) }

    (21..30).each { |n| it { expect(optimizer.best_price(n)).to eq(250) } }
    (31..55).each { |n| it { expect(optimizer.best_price(n)).to eq(300) } }
    it { expect(optimizer.best_price(56)).to eq(380) }
    it { expect(optimizer.best_price(57)).to eq(380) }
    it { expect(optimizer.best_price(58)).to eq(380) }
    it { expect(optimizer.best_price(59)).to eq(380) }
    it { expect(optimizer.best_price(60)).to eq(400) }
    it { expect(optimizer.best_price(61)).to eq(400) }
    it { expect(optimizer.best_price(62)).to eq(400) }
    it { expect(optimizer.best_price(63)).to eq(400) }
    it { expect(optimizer.best_price(64)).to eq(400) }
    it { expect(optimizer.best_price(65)).to eq(400) }
    it { expect(optimizer.best_price(66)).to eq(480) }
  end

  describe '#configuration' do
    it { expect { optimizer.configuration(-1) }.to raise_error ArgumentError }
    it { expect(optimizer.configuration(0)).to eq({}) }
    it { expect(optimizer.configuration(1)).to eq(4 => 1) }
    it { expect(optimizer.configuration(2)).to eq(4 => 1) }
    it { expect(optimizer.configuration(3)).to eq(4 => 1) }
    it { expect(optimizer.configuration(4)).to eq(4 => 1) }
    it { expect(optimizer.configuration(5)).to eq(10 => 1) }
    it { expect(optimizer.configuration(6)).to eq(10 => 1) }
    it { expect(optimizer.configuration(7)).to eq(10 => 1) }
    it { expect(optimizer.configuration(8)).to eq(10 => 1) }
    it { expect(optimizer.configuration(9)).to eq(10 => 1) }
    it { expect(optimizer.configuration(10)).to eq(10 => 1) }
    it { expect(optimizer.configuration(11)).to eq(4 => 1, 10 => 1) }
    it { expect(optimizer.configuration(12)).to eq(4 => 1, 10 => 1) }
    it { expect(optimizer.configuration(13)).to eq(4 => 1, 10 => 1) }
    it { expect(optimizer.configuration(14)).to eq(4 => 1, 10 => 1) }
    it { expect(optimizer.configuration(15)).to eq(10 => 2) }
    it { expect(optimizer.configuration(16)).to eq(10 => 2) }
    it { expect(optimizer.configuration(17)).to eq(10 => 2) }
    it { expect(optimizer.configuration(18)).to eq(10 => 2) }
    it { expect(optimizer.configuration(19)).to eq(10 => 2) }
    it { expect(optimizer.configuration(20)).to eq(10 => 2) }

    (21..30).each { |n| it { expect(optimizer.configuration(n)).to eq(30 => 1) } }
    (31..55).each { |n| it { expect(optimizer.configuration(n)).to eq(55 => 1) } }
    it { expect(optimizer.configuration(56)).to eq(4 => 1, 55 => 1) }
    it { expect(optimizer.configuration(57)).to eq(4 => 1, 55 => 1) }
    it { expect(optimizer.configuration(58)).to eq(4 => 1, 55 => 1) }
    it { expect(optimizer.configuration(59)).to eq(4 => 1, 55 => 1) }
    it { expect(optimizer.configuration(60)).to eq(10 => 1, 55 => 1) }
    it { expect(optimizer.configuration(61)).to eq(10 => 1, 55 => 1) }
    it { expect(optimizer.configuration(62)).to eq(10 => 1, 55 => 1) }
    it { expect(optimizer.configuration(63)).to eq(10 => 1, 55 => 1) }
    it { expect(optimizer.configuration(64)).to eq(10 => 1, 55 => 1) }
    it { expect(optimizer.configuration(65)).to eq(10 => 1, 55 => 1) }
    it { expect(optimizer.configuration(66)).to eq(4 => 1, 10 => 1, 55 => 1) }
  end
end
