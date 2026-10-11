# frozen_string_literal: true

require 'rails_helper'

module Reports
  RSpec.describe CateringReport do
    let(:wedding) { create(:wedding) }

    before do
      create(:menu_option, wedding:, name: :mushroom)

      alice = create(:guest, name: 'Alice', wedding:, menu_choice: :meat, menu_restrictions: 'Allergic to peas')
      bob = create(:guest, name: 'Bob', wedding:, menu_choice: :meat, menu_restrictions: nil)
      charlie = create(:guest, name: 'Charlie', wedding:, menu_choice: :fish, menu_restrictions: nil)
      dave = create(:guest, name: 'Dave', wedding:, menu_choice: :mushroom, menu_restrictions: nil)
      erin = create(:guest, name: 'Erin', wedding:, menu_choice: :vegetarian, menu_restrictions: nil)
      frank = create(:guest, name: 'Frank', wedding:, menu_choice: :child, menu_restrictions: nil)

      wedding.invitations.create!.tap do |invitation|
        alice.update!(invitation:)
        charlie.update!(invitation:)
      end

      simulation = create(:tables_arrangement, system: true, wedding:)
      table_a = create(:table, wedding:, number: 1, name: 'Foo', tables_arrangement: simulation)
      table_b = create(:table, wedding:, number: 2, tables_arrangement: simulation)

      simulation.seats.create!(wedding:, guest: alice, table: table_a)
      simulation.seats.create!(wedding:, guest: bob, table: table_a)
      simulation.seats.create!(wedding:, guest: charlie, table: table_a)

      simulation.seats.create!(wedding:, guest: dave, table: table_b)
      simulation.seats.create!(wedding:, guest: erin, table: table_b)
      simulation.seats.create!(wedding:, guest: frank, table: table_b)
    end

    describe '#to_h' do
      let(:report) { described_class.new(wedding:).to_h }
      let(:rows) { report[:rows] }
      let(:columns) { report[:columns] }

      it 'includes the columns needed for the report', :aggregate_failures do
        expect(columns.count).to eq(4)

        expect(columns[0]).to eq(header: 'Table', field: :table)
        expect(columns[1]).to eq(header: 'Name', field: :name)
        expect(columns[2]).to eq(header: 'Menu choice', field: :menu_choice)
        expect(columns[3]).to eq(header: 'Menu restrictions', field: :menu_restrictions)
      end

      it 'returns a row for each guest', :aggregate_failures do
        expect(rows.count).to eq(6)

        expect(rows.dig(0, 'table')).to eq('Foo')
        expect(rows.dig(0, 'name')).to eq('Alice')
        expect(rows.dig(0, 'menu_choice')).to eq('Meat')
        expect(rows.dig(0, 'menu_restrictions')).to eq('Allergic to peas')

        expect(rows.dig(1, 'table')).to eq('Foo')
        expect(rows.dig(1, 'name')).to eq('Charlie')
        expect(rows.dig(1, 'menu_choice')).to eq('Fish')
        expect(rows.dig(1, 'menu_restrictions')).to be_nil

        expect(rows.dig(2, 'table')).to eq('Foo')
        expect(rows.dig(2, 'name')).to eq('Bob')
        expect(rows.dig(2, 'menu_choice')).to eq('Meat')
        expect(rows.dig(2, 'menu_restrictions')).to be_nil

        expect(rows.dig(3, 'table')).to eq('2')
        expect(rows.dig(3, 'name')).to eq('Dave')
        expect(rows.dig(3, 'menu_choice')).to eq('Mushroom')
        expect(rows.dig(3, 'menu_restrictions')).to be_nil

        expect(rows.dig(4, 'table')).to eq('2')
        expect(rows.dig(4, 'name')).to eq('Erin')
        expect(rows.dig(4, 'menu_choice')).to eq('Vegetarian')
        expect(rows.dig(4, 'menu_restrictions')).to be_nil

        expect(rows.dig(5, 'table')).to eq('2')
        expect(rows.dig(5, 'name')).to eq('Frank')
        expect(rows.dig(5, 'menu_choice')).to eq('Child menu')
        expect(rows.dig(5, 'menu_restrictions')).to be_nil
      end
    end

    describe '#to_csv' do
      let(:csv) { CSV.parse(described_class.new(wedding:).to_csv, headers: true) }

      it 'returns a CSV string with the right information' do
        expect(csv.headers).to eq(['Table', 'Name', 'Menu choice', 'Menu restrictions'])

        rows = csv.to_a[1..]

        expect(rows[0]).to eq(['Foo', 'Alice', 'Meat', 'Allergic to peas'])
        expect(rows[1]).to eq(['Foo', 'Charlie', 'Fish', nil])
        expect(rows[2]).to eq(['Foo', 'Bob', 'Meat', nil])
        expect(rows[3]).to eq(['2', 'Dave', 'Mushroom', nil])
        expect(rows[4]).to eq(['2', 'Erin', 'Vegetarian', nil])
        expect(rows[5]).to eq(['2', 'Frank', 'Child menu', nil])
      end
    end
  end
end
