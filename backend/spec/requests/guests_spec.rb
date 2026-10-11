# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'guests' do
  include_context 'when API request is authenticated'

  before do
    group = create(:group, wedding:)
    create_list(:guest, 2, wedding:, group:)
  end

  path '/{slug}/guests' do
    get('list guests') do
      tags 'Guests'
      produces 'application/json', 'text/csv'
      parameter Swagger::Schema::SLUG
      security [{ oauth2: ['guests'] }]
      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 required: %i[id name status group],
                 properties: {
                   id: { type: :string, format: :uuid },
                   name: { type: :string },
                   status: { type: :string, enum: Guest.statuses.keys },
                   menu_choice: { type: :string, enum: Guest::DEFAULT_MENU_OPTIONS, nullable: true },
                   menu_restrictions: { type: :string, nullable: true },
                   special_requests: { type: :string, nullable: true },
                   group: { type: :object,
                            required: %i[id name],
                            properties: {
                              id: { type: :string, format: :uuid },
                              name: { type: :string }
                            } }
                 }
               }
        run_test!
      end
      regular_api_responses
    end

    post('create guest') do
      tags 'Guests'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['guests', 'guests:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[guest],
        properties: {
          guest: {
            type: :object,
            required: %i[name status],
            properties: {
              name: { type: :string },
              group_id: { type: :string, format: :uuid },
              status: { type: :string, enum: Guest.statuses.keys }
            }
          }
        }
      }

      let(:body) do
        {
          guest: {
            name: 'John Doe',
            status: 'invited',
            group_id: Group.first.id
          }
        }
      end

      response_empty201
      response400
      regular_api_responses
    end
  end

  path '/{slug}/guests/{id}' do
    let(:id) { Guest.first.id }
    patch('update guest') do
      tags 'Guests'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['guests', 'guests:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[guest],
        properties: {
          guest: {
            type: :object,
            required: %i[name status],
            properties: {
              name: { type: :string },
              status: { type: :string, enum: Guest.statuses.keys },
              group_id: { type: :string, format: :uuid },
              menu_choice: { type: :string, enum: Guest::DEFAULT_MENU_OPTIONS },
              menu_restrictions: { type: :string },
              needs_bus: { type: :boolean },
              special_requests: { type: :string }
            }
          }
        }
      }

      let(:body) do
        {
          guest: {
            name: 'Jane Doe',
            status: 'confirmed',
            group_id: Group.first.id,
            menu_choice: 'fish',
            menu_restrictions: 'lactose, gluten',
            needs_bus: false,
            special_requests: 'Need a wheelchair'
          }
        }
      end

      response(200, 'Success') do
        produces 'application/json'
        schema type: :object
        run_test! do
          guest = Guest.find(id)

          expect(guest.name).to eq('Jane Doe')
          expect(guest).to be_confirmed
          expect(guest.group).to eq(Group.first)
          expect(guest.menu_choice).to eq('fish')
          expect(guest.menu_restrictions).to eq('lactose, gluten')
          expect(guest.needs_bus).to be false
          expect(guest.special_requests).to eq('Need a wheelchair')
        end
      end

      response400
      response404

      context 'when only the menu_choice is updated' do
        let(:body) do
          {
            guest: {
              menu_choice: 'fish'
            }
          }
        end

        response(200, 'Success') do
          produces 'application/json'
          schema type: :object
          run_test! do
            guest = Guest.find(id)

            expect(guest.menu_choice).to eq('fish')
          end
        end
      end

      context 'when the menu choice is identified by its id' do
        let(:body) do
          {
            guest: {
              menu_choice: wedding.menu_options.where(name: 'fish').pick(:id)
            }
          }
        end

        response(200, 'Success') do
          produces 'application/json'
          schema type: :object
          run_test! do
            guest = Guest.find(id)

            expect(guest.menu_choice).to eq('fish')
          end
        end
      end
    end

    delete('delete guest') do
      tags 'Guests'
      produces 'application/json'
      security [{ oauth2: ['guests', 'guests:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :id, in: :path, schema: { type: :string, format: :uuid }

      response_empty200
      response404
      regular_api_responses
    end
  end

  path '/{slug}/guests/import' do
    before do
      wedding.guests.delete_all
      wedding.groups.delete_all

      create(:guest, wedding:, name: 'Yussef', group: create(:group, wedding:, name: 'Work'))
      create(:guest, wedding:, name: 'Zacharias', group: create(:group, wedding:, name: 'Chess club'))
    end

    post('bulk import') do
      tags 'Guests'
      consumes 'application/json'
      produces 'application/json'
      security [{ oauth2: ['guests', 'guests:write'] }]
      parameter Swagger::Schema::SLUG
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: %i[records delete_existing_records],
        properties: {
          records: {
            type: :array,
            items: {
              type: :object,
              required: %i[name],
              properties: {
                name: { type: :string },
                group_name: { type: :string, nullable: true },
                status: { type: :string, enum: Guest.statuses.keys, nullable: true },
                menu_choice: { type: :string, enum: Guest::DEFAULT_MENU_OPTIONS, nullable: true },
                menu_restrictions: { type: :string, nullable: true },
                special_requests: { type: :string, nullable: true },
                needs_bus: { type: :string, enum: %i[true false], nullable: true }
              }
            }

          },
          delete_existing_records: { type: :boolean }
        }
      }

      let(:body) do
        {
          records: [
            { name: 'Alice', group_name: 'Work', status: 'confirmed', menu_choice: 'meat',
              menu_restrictions: 'Allergic to peanuts', special_requests: '', needs_bus: 'false' },
            { name: 'Bob', group_name: 'Work', status: 'declined', menu_choice: 'fish', menu_restrictions: '',
              special_requests: 'Nothing', needs_bus: 'false' },
            { name: 'Charlie', group_name: 'School', status: 'invited', menu_choice: 'vegetarian',
              menu_restrictions: '', special_requests: '', needs_bus: 'true' },
            { name: 'Dustin', group_name: 'School', status: 'tentative', menu_choice: 'child' },
            { name: 'Ellie', group_name: 'Work', status: 'considered', menu_choice: 'meat', menu_restrictions: '',
              special_requests: '', needs_bus: 'true' },
            { name: 'Francis', group_name: '', status: '', menu_choice: '' }
          ], delete_existing_records:
        }
      end
      let(:delete_existing_records) { true }

      context 'when delete_existing_records is true' do
        let(:delete_existing_records) { true }

        response_empty201 do
          wedding.reload

          expect(wedding.guests.pluck(:name)).to contain_exactly('Alice', 'Bob', 'Charlie', 'Dustin', 'Ellie',
                                                                 'Francis')
          expect(wedding.groups.pluck(:name)).to contain_exactly('Work', 'School')

          expect(wedding.groups.find_by(name: 'Work').guests.pluck(:name)).to contain_exactly('Alice', 'Bob', 'Ellie')
          expect(wedding.groups.find_by(name: 'School').guests.pluck(:name)).to contain_exactly('Charlie', 'Dustin')

          alice = wedding.guests.find_by(name: 'Alice')
          expect(alice.group.name).to eq('Work')
          expect(alice.status).to eq('confirmed')
          expect(alice.menu_choice).to eq('meat')
          expect(alice.menu_restrictions).to eq('Allergic to peanuts')
          expect(alice.special_requests).to be_nil
          expect(alice.needs_bus).to be_falsey

          francis = wedding.guests.find_by(name: 'Francis')
          expect(francis.group).to be_nil
          expect(francis.status).to eq('considered') # default
          expect(francis.menu_choice).to be_nil
          expect(francis.menu_restrictions).to be_nil
          expect(francis.special_requests).to be_nil
          expect(francis.needs_bus).to be_truthy # default
        end
      end

      context 'when delete_existing_records is false' do
        let(:delete_existing_records) { false }

        response_empty201 do
          wedding.reload

          expect(wedding.guests.pluck(:name)).to contain_exactly('Yussef', 'Zacharias', 'Alice', 'Bob', 'Charlie',
                                                                 'Dustin', 'Ellie', 'Francis')
          expect(wedding.groups.pluck(:name)).to contain_exactly('Chess club', 'Work', 'School')

          expect(wedding.groups.find_by(name: 'Work').guests.pluck(:name)).to contain_exactly('Alice', 'Bob', 'Ellie',
                                                                                              'Yussef')

          alice = wedding.guests.find_by(name: 'Alice')
          expect(alice.group.name).to eq('Work')
          expect(alice.status).to eq('confirmed')
          expect(alice.menu_choice).to eq('meat')
          expect(alice.menu_restrictions).to eq('Allergic to peanuts')
          expect(alice.special_requests).to be_nil
          expect(alice.needs_bus).to be_falsey

          francis = wedding.guests.find_by(name: 'Francis')
          expect(francis.group).to be_nil
          expect(francis.status).to eq('considered') # default
          expect(francis.menu_choice).to be_nil
          expect(francis.menu_restrictions).to be_nil
          expect(francis.special_requests).to be_nil
          expect(francis.needs_bus).to be_truthy # default
        end
      end

      context 'when new menu choices are defined' do
        let(:body) do
          {
            records: [
              { name: 'Alice', group_name: 'Work', status: 'confirmed', menu_choice: 'meat',
                menu_restrictions: 'Allergic to peanuts', special_requests: '', needs_bus: 'false' },
              { name: 'Bob', group_name: 'Work', status: 'declined', menu_choice: 'fish', menu_restrictions: '',
                special_requests: 'Nothing', needs_bus: 'false' },
              { name: 'Charlie', group_name: 'School', status: 'invited', menu_choice: 'vegetarian',
                menu_restrictions: '', special_requests: '', needs_bus: 'true' },
              { name: 'Dustin', group_name: 'School', status: 'tentative', menu_choice: 'child' },
              { name: 'Ellie', group_name: 'Work', status: 'considered', menu_choice: 'Octopus', menu_restrictions: '',
                special_requests: '', needs_bus: 'true' },
              { name: 'Francis', group_name: '', status: '', menu_choice: '' }
            ], delete_existing_records:
          }
        end

        response_empty201 do
          expect(wedding.menu_options.pluck(:name)).to contain_exactly('meat', 'fish', 'vegetarian', 'child', 'Octopus')
          expect(wedding.guests.find_by(name: 'Ellie').menu_choice).to eq('Octopus')
        end
      end

      regular_api_responses
    end
  end
end
