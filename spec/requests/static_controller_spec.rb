# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StaticController, type: :request do
  describe '#index' do
    it 'returns success status' do
      get '/'
      expect(response.status).to eq(200)
    end

    context 'when user signed in' do
      let(:user) { create(:user, :youth) }

      before { sign_in(user) }

      it 'renders signed-in-index' do
        get('/')

        expect(response).to render_template('index-signed-in')
      end
    end

    context 'when user anonymous' do
      it 'renders index' do
        get('/')

        expect(response).to render_template('index')
      end
    end
  end
end
