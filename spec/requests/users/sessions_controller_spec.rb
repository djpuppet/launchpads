# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController, type: :request do
  describe '#create' do
    context 'with invalid credentials' do
      context 'when json' do
        before do
          post(
            '/users/sign_in',
            params:  { user: { email: 'invalid', password: 'invalid' } },
            headers: { 'accept' => 'application/json' }
          )
        end

        it 'returns 401 status' do
          expect(response.status).to eq(401)
        end
      end

      context 'when html' do
        it 'returns 200 status and renders form' do
          post '/users/sign_in', params: { user: { email: 'invalid', password: 'invalid' } }
          expect(response.status).to eq(200)
          expect(response).to render_template(:new)
        end
      end
    end

    context 'with valid credentials' do
      let(:user) { create(:user, password: 'qwerty') }

      context 'when json' do
        before do
          post(
            '/users/sign_in',
            params:  { user: { email: user.email, password: user.password } },
            headers: { 'accept' => 'text/javascript, */*' }
          )
        end

        it 'redirects to root' do
          expect(response).to redirect_to('/profile')
        end
      end

      context 'when html' do
        it 'redirects to root' do
          post '/users/sign_in', params: { user: { email: user.email, password: user.password } }
          expect(response).to redirect_to('/profile')
        end
      end
    end

    context 'when user does not have a role' do
      let(:user) { create(:user, password: 'qwerty') }

      it 'redirects user to the profile path' do
        post '/users/sign_in', params: { user: { email: user.email, password: user.password } }
        expect(response).to redirect_to('/profile')
      end
    end

    context 'when the user is a youth' do
      let(:user) { create(:user, :youth, :with_valid_parameters, password: 'qwerty') }

      it 'redirects user to the root path' do
        post '/users/sign_in', params: { user: { email: user.email, password: user.password } }
        expect(response).to redirect_to('/')
      end
    end

    context 'when the user is a social worker' do
      let(:user) { create(:user, :social_worker, :with_valid_parameters, password: 'qwerty') }

      it 'redirects user to the surveys path' do
        post '/users/sign_in', params: { user: { email: user.email, password: user.password } }
        expect(response).to redirect_to('/surveys')
      end
    end

    context 'when the user is a host' do
      let(:user) { create(:user, :host, :with_valid_parameters, password: 'qwerty') }

      it 'redirects user to the surveys path' do
        post '/users/sign_in', params: { user: { email: user.email, password: user.password } }
        expect(response).to redirect_to('/listings')
      end
    end

    context 'when the user is an youth and is banned' do
      let(:user) { create(:user, :youth, :with_valid_parameters, banned: true) }

      before do
        post '/users/sign_in', params: { user: { email: user.email, password: user.password } }
      end

      it 'redirects to root' do
        expect(response).to redirect_to('/')
      end

      it 'presents proper flash message' do
        expect(flash[:notice]).to eq('This account has been suspended by admin.')
      end
    end

    context 'when the user is an admin' do
      let(:user) { create(:user, :admin, :with_valid_parameters, password: 'qwerty') }

      it 'redirects user to the admin dashboard' do
        post '/users/sign_in', params: { user: { email: user.email, password: user.password } }
        expect(response).to redirect_to('/admin')
      end
    end
  end
end
