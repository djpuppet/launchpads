# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::PasswordsController, type: :request do
  describe '#create' do
    let(:format) { 'html' }
    let(:user) { create(:user) }

    before do
      post(
        "/users/password.#{format}",
        params: { user: { email: user.email } }
      )
    end

    context 'when html request' do
      context 'with valid user data' do
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

      context 'with invalid user data' do
        let(:user) { OpenStruct.new(email: Faker::Internet.email) }

        it 'responds as text/html' do
          expect(response.content_type).to include('text/html')
        end

        it 'responds with success status' do
          expect(response.status).to eq(200)
        end
      end
    end

    context 'when json request' do
      let(:format) { 'json' }

      context 'with valid user data' do
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

      context 'with invalid user data' do
        let(:user) { OpenStruct.new(email: Faker::Internet.email) }

        it 'responds as application/json' do
          expect(response.content_type).to include('application/json')
        end

        it 'responds with error status' do
          expect(response.status).to eq(422)
        end
      end
    end
  end
end
