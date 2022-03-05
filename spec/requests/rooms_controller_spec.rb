# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomsController, type: :request do
  describe '#new' do
    before { sign_in user }

    context 'when user is not a host' do
      let(:user) { create(:user, :youth) }

      it 'redirects user to root path' do
        get '/listings/new'
        expect(response).to redirect_to('/')
        expect(response.status).to eq(302)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when user is a host' do
      let(:user) { create(:user, :host, :approved) }

      it 'has succeeded response status' do
        get '/listings/new'
        expect(response.status).to eq(200)
      end
    end
  end

  describe '#my' do
    before { sign_in user }

    context 'when user is not a host' do
      let(:user) { create(:user, :youth) }

      it 'redirects user to root path' do
        get '/listings/my'
        expect(response).to redirect_to('/')
        expect(response.status).to eq(302)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when user is a host' do
      let(:user) { create(:user, :host) }

      it 'has succeeded response status' do
        get '/listings/my'
        expect(response.status).to eq(200)
      end
    end
  end

  describe '#create' do
    let(:mail) { double }

    before do
      allow(RoomMailer).to receive(:create_room).and_return(mail)
      allow(mail).to receive(:deliver_later)
      sign_in user
    end

    context 'when user is not a host' do
      let(:user) { create(:user, :youth) }
      let(:params) { attributes_for(:room, :with_valid_parameters) }

      it 'redirects user to root path' do
        post '/listings', params: { room: params }
        expect(response).to redirect_to('/')
        expect(response.status).to eq(302)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when user is a host' do
      let(:user) { create(:user, :host, :approved) }
      let(:params) { attributes_for(:room, :with_valid_parameters) }

      context 'when room is invalid' do
        let(:invalid_param) { Faker::Lorem.word }

        before do
          post '/listings', params: { room: { room_type: invalid_param } }
        end

        it 'does not create a room' do
          expect(flash[:error]).to eq('You cannot submit this without completing all required fields')
        end

        it "doesn't send the notification" do
          expect(RoomMailer).not_to have_received(:create_room)
          expect(mail).not_to have_received(:deliver_later)
        end
      end

      context 'when room is valid' do
        before do
          post '/listings', params: { room: params }
        end

        it 'creates a room' do
          expect(flash[:notice]).to eq('The listing has been successfully created')
          expect(response).to redirect_to('/')
        end

        it 'sends the notification' do
          expect(RoomMailer).to have_received(:create_room)
          expect(mail).to have_received(:deliver_later)
        end
      end

      context 'when user is not approved' do
        let(:user) { create(:user, :host) }

        it 'sends the proper message' do
          post '/listings', params: { room: params }
          expect(flash[:notice]).to eq(I18n.t('activerecord.errors.models.room.create.user_unapproved'))
          expect(response).to redirect_to('/')
        end
      end
    end
  end

  describe '#edit' do
    let(:user) { create(:user, :host, :approved) }

    before { sign_in user }

    context 'when user is the host who created the room' do
      let(:room) { create(:room, :with_valid_parameters, user: user) }

      it 'returns status 200' do
        get "/listings/#{room.id}/edit"
        expect(response.status).to eq(200)
      end
    end

    context 'when user is the host who did not create the room' do
      let(:room) { create(:room, :with_valid_parameters) }

      it 'redirects user to root path' do
        get "/listings/#{room.id}/edit"
        expect(response).to redirect_to('/')
        expect(response.status).to eq(302)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end
  end

  describe '#update' do
    let(:user) { create(:user, :host, :approved) }

    before { sign_in user }

    context 'when user is the host who did not create the room' do
      let(:room) { create(:room, :with_valid_parameters) }
      let(:params) { attributes_for(:room, :with_valid_parameters) }

      it 'redirects user to root path' do
        put "/listings/#{room.id}", params: { room: params }
        expect(response).to redirect_to('/')
        expect(response.status).to eq(302)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when user is the host who created the room' do
      let(:room) { create(:room, :with_valid_parameters, user: user) }
      let(:params) { attributes_for(:room, :with_valid_parameters) }
      let(:invalid_params) { Faker::Lorem.word }

      context 'when room is valid' do
        it 'updates the room' do
          put "/listings/#{room.id}", params: { room: params }
          expect(flash[:notice]).to eq('The listing has been successfully updated')
          expect(response).to redirect_to('/')
        end
      end

      context 'when room is invalid' do
        it 'does not update the room' do
          put "/listings/#{room.id}", params: { room: { room_type: invalid_params } }
          expect(flash[:error]).to eq('You cannot submit this without completing all required fields')
        end
      end
    end
  end

  describe '#index' do
    let!(:rooms) do
      rooms = create_list(:room, 3, :with_valid_parameters)
      rooms.map.with_index do |room, index|
        room.update(
          rent:             (index + 1) * 100,
          utilities:        0,
          accept_children:  index.odd? ? 'yes' : %w[no possibly].sample,
          pet_friendly:     index.odd? ? %w[cats dogs] : [],
          smoking:          index.odd? ? 'no' : %w[inside outside].sample,
          duration_of_stay: index + 6,
          user:             create(:user, :host, :with_valid_parameters, :approved)
        )
        room
      end
    end

    before do
      allow_any_instance_of(described_class).to receive(:pagy).and_call_original
    end

    it 'paginates results' do
      get '/listings'

      expect(controller).to have_received(:pagy)
    end

    it 'applies price filters' do
      get '/listings?room_filters[max_price]=200'

      expect(response.body).to include(rooms[0].title, rooms[1].title)
      expect(response.body).not_to include(rooms[2].title)
    end

    it 'applies child_friendly filter' do
      get '/listings?room_filters[child_friendly]=1'

      expect(response.body).to include(rooms[1].title)
      expect(response.body).not_to include(rooms[0].title, rooms[2].title)
    end

    it 'applies pet_friendly filter' do
      get '/listings?room_filters[pet_friendly]=1'

      expect(response.body).to include(rooms[1].title)
      expect(response.body).not_to include(rooms[0].title, rooms[2].title)
    end

    context 'with duration_of_stay filter value' do
      it 'applies the filter' do
        get '/listings?room_filters[duration_of_stay]=7'

        expect(response.body).not_to include(rooms[0].title)
        expect(response.body).to include(rooms[1].title, rooms[2].title)
      end
    end
  end

  describe '#validate' do
    let(:user) { create(:user, :host) }

    before { sign_in user }

    context 'when new record is created' do
      let(:params) { attributes_for(:room, :with_valid_parameters) }
      let(:invalid_params) { Faker::Lorem.word }

      context 'when room is valid' do
        it 'responds with status 200' do
          patch '/listings/new/validate', params: { room: params }
          expect(response.status).to eq(200)
        end
      end

      context 'with empty photo' do
        it 'responds with status 200' do
          patch '/listings/new/validate', params: { room: params.merge(photos: ['']) }
          expect(response.status).to eq(200)
        end
      end

      context 'when room is invalid' do
        it 'responds with status 422' do
          patch '/listings/new/validate', params: { room: { room_type: invalid_params } }
          expect(response.status).to eq(422)
        end
      end
    end

    context 'when record is updated' do
      let(:room) { create(:room, :with_valid_parameters, user: user) }
      let(:params) { attributes_for(:room, :with_valid_parameters) }
      let(:invalid_params) { Faker::Lorem.word }

      context 'when room is valid' do
        it 'responds with status 200' do
          patch "/listings/#{room.id}/validate", params: { room: params }
          expect(response.status).to eq(200)
        end
      end

      context 'with empty photo' do
        it 'responds with status 200' do
          patch '/listings/new/validate', params: { room: params.merge(photos: ['']) }
          expect(response.status).to eq(200)
        end
      end

      context 'when room is invalid' do
        it 'responds with status 422' do
          patch "/listings/#{room.id}/validate", params: { room: { room_type: invalid_params } }
          expect(response.status).to eq(422)
        end
      end
    end
  end

  describe '#hide' do
    let(:user) { create(:user, :host) }
    let(:room) { create(:room, :with_valid_parameters, hidden: false, user: user) }

    before { sign_in user }

    it 'hides the room' do
      expect { post "/listings/#{room.id}/hide" }.to(change { room.reload.hidden }.from(false).to(true))
    end

    it 'shows the room' do
      room.hide!
      expect { post "/listings/#{room.id}/unhide" }.to(change { room.reload.hidden }.from(true).to(false))
    end
  end
end
