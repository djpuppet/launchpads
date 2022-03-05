# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  describe '#banned' do
    context 'when a user is signed in and just has been banned' do
      let(:user) { create(:user, :youth, :with_valid_parameters) }
      let(:path) { '/profile' }

      before do
        sign_in user
        get "/profile/#{user.role}"
      end

      it 'logs out current user' do
        expect(response.status).to eq(200)
        user.update(banned: true)
        get path
        expect(response).to redirect_to('/')
      end

      it 'presents a proper message' do
        expect(response.status).to eq(200)
        user.update(banned: true)
        get path
        expect(flash[:notice]).to eq('This account has been suspended by admin.')
      end
    end
  end
end
