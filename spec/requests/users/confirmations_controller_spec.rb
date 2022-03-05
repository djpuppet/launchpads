# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::ConfirmationsController, type: :request do
  describe '#create' do
    let(:format) { 'html' }

    before do
      post(
        "/users/confirmation.#{format}",
        { params: { user: { email: user.email } } }
      )
    end

    context 'when html request' do
      context 'with unconfirmed user' do
        let(:user) { create(:user, confirmed_at: nil) }

        it 'responds as text/html' do
          expect(response.content_type).to include('text/html')
        end

        it 'responds with redirect' do
          expect(response.status).to eq(302)
          expect(response).to redirect_to('/')
        end

        it 'responds with flash notice' do
          expect(flash).to be_key(:notice)
        end
      end

      context 'with confirmed user' do
        let(:user) { create(:user) }

        before do
          user.confirm
        end

        it 'responds as text/html' do
          expect(response.content_type).to include('text/html')
        end

        it 'responds with error status' do
          expect(response.body).to include('Email was already confirmed, please try signing in')
        end
      end
    end

    context 'when json request' do
      let(:format) { 'json' }

      context 'with unconfirmed user' do
        let(:user) { create(:user, confirmed_at: nil) }

        it 'responds as application/json' do
          expect(response.content_type).to include('application/json')
        end

        it 'responds with success status' do
          expect(response.status).to eq(201)
        end

        it 'clears flash messages' do
          expect(flash).not_to be_key(:notice)
        end

        it 'includes flash notice in body' do
          expect(JSON.parse(response.body)).to be_key('notice')
        end
      end

      context 'with confirmed user' do
        let(:user) { create(:user) }

        before do
          user.confirm
        end

        it 'responds as application/json' do
          expect(response.content_type).to include('application/json')
        end

        it 'responds with error status' do
          expect(response.status).to eq(422)
        end
      end
    end
  end

  describe '#show' do
    context 'with unconfirmed account' do
      let(:user) { create(:user, confirmed_at: nil) }

      it 'redirects to sign-in form' do
        get("/users/confirmation?confirmation_token=#{user.confirmation_token}")
        expect(response).to redirect_to('/')
      end
    end

    context 'with confirmed account' do
      let(:user) { create(:user, confirmed_at: nil) }
      let(:token) { user.confirmation_token }

      before do
        user.confirm
      end

      context 'when html request' do
        before do
          get("/users/confirmation?confirmation_token=#{token}")
        end

        it 'responds in html format' do
          expect(response.content_type).to include('text/html')
        end

        it 'responds with redirect' do
          expect(response).to redirect_to('/')
        end

        it 'stores confirmation errors in flash' do
          expect(flash).to be_key(:confirmation_errors)
        end
      end
    end
  end
end
