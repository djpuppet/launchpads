# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConversationsController, type: :request do
  describe '#index' do
    let(:user) { create(:user, :youth, :with_valid_parameters, :approved) }
    let!(:user_conversations) do
      create_list(:conversation, 2, users: [user, create(:user, :host, :with_valid_parameters, :approved)])
    end
    let!(:other_conversations) do
      create_list(:conversation, 2)
    end

    before do
      create(:message, conversation: user_conversations.first)
      create(:message, conversation: other_conversations.first)

      sign_in user
      get '/conversations'
    end

    it 'includes the conversations which only contain signed-in user' do
      expect(response.body).to include(conversation_path(user_conversations.first))
    end

    it 'excludes empty conversations' do
      expect(response.body).not_to include(conversation_path(user_conversations.second))
    end

    it 'excludes other users conversations' do
      expect(response.body).not_to include(*other_conversations.map { |c| conversation_path(c) })
    end

    it 'returns status 200' do
      expect(response.status).to eq(200)
    end
  end

  describe '#show' do
    let(:conversation) { create(:conversation, :with_messages) }
    let(:user) { conversation.users.select(&:youth?).first }

    before do
      sign_in user
      get "/conversations/#{conversation.id}"
    end

    it 'enters to the specific conversation' do
      expect(response.body).to include conversation.users.reject { |u| u == user }.first.username
    end

    it 'returns status 200' do
      expect(response.status).to eq(200)
    end
  end

  describe '#find_or_create' do
    let(:user) { create(:user, :youth, :with_valid_parameters, :approved) }
    let(:host) { create(:user, :host, :with_valid_parameters, :approved) }

    context "when conversation doesn't exist" do
      before do
        sign_in user
        get "/conversations/with/#{host.id}"
      end

      it 'creates new conversation' do
        conversation = Conversation.first
        expect(conversation.users).to include host
        expect(conversation.users).to include user
      end

      it 'redirects to new conversation' do
        expect(response).to redirect_to("/conversations/#{Conversation.first.id}")
      end
    end

    context 'when conversation exists' do
      let!(:conversation) { create(:conversation, users: [user, host]) }

      before do
        sign_in user
        get "/conversations/with/#{host.id}"
      end

      it 'finds specific conversation' do
        expect(Conversation.last).to eq conversation
      end

      it 'redirects to existed conversation' do
        expect(response).to redirect_to("/conversations/#{conversation.id}")
      end
    end
  end

  describe '#ignore' do
    let(:users) do
      [
        create(:user, :youth, :with_valid_parameters, :approved),
        create(:user, :host, :with_valid_parameters, :approved)
      ]
    end
    let!(:conversation) { create(:conversation, users: users) }

    before do
      sign_in users.sample
      post "/conversations/#{conversation.id}/ignore"
    end

    it 'redirects to conversations list' do
      expect(response).to redirect_to('/conversations')
      expect(flash[:notice]).to eq('Conversation is muted')
    end
  end

  describe '#unignore' do
    let(:users) do
      [
        create(:user, :youth, :with_valid_parameters, :approved),
        create(:user, :host, :with_valid_parameters, :approved)
      ]
    end

    let!(:conversation) { create(:conversation, users: users) }

    before do
      sign_in users.sample
      post "/conversations/#{conversation.id}/unignore"
    end

    it 'redirects to conversations list' do
      expect(response).to redirect_to('/conversations')
      expect(flash[:notice]).to eq('Conversation is not muted anymore')
    end
  end

  describe '#invite_social_worker' do
    let(:host) { create(:user, :host, :with_valid_parameters, :approved) }
    let(:youth) { create(:user, :youth, :with_valid_parameters, :approved) }
    let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }
    let(:conversation) { create(:conversation, users: [youth, host]) }

    context 'when user has social worker' do
      before do
        youth.update(social_worker: social_worker)
        sign_in youth
        get "/conversations/#{conversation.id}/invite-social-worker"
      end

      it 'redirects to the conversation' do
        expect(response).to redirect_to("/conversations/#{conversation.id}")
      end

      it 'is added to the conversation' do
        conversation.reload
        expect(conversation.users.pluck(:role)).to include(:social_worker)
      end

      it 'renders the proper message' do
        expect(flash[:notice]).to eq('Social worker was invited to the conversation')
      end
    end

    context "when user doesn't have social worker" do
      let(:youth) { create(:user, :youth, :with_valid_parameters, :approved, social_worker: nil) }

      before do
        sign_in youth
        get "/conversations/#{conversation.id}/invite-social-worker"
      end

      it 'redirects to the conversation' do
        expect(response).to redirect_to("/conversations/#{conversation.id}")
      end

      it 'is added to the conversation' do
        expect(conversation.users.pluck(:role)).not_to include('social_worker')
      end

      it 'renders the proper message' do
        expect(flash[:notice]).to eq('Social worker could not be found!')
      end
    end
  end

  describe '#report' do
    let(:conversation) { create(:conversation) }
    let(:host) { conversation.users.find_by(role: :host) }
    let(:mail) { double }

    before do
      allow(ConversationMailer).to receive(:inappropriate_content).and_return(mail)
      allow(mail).to receive(:deliver_later)
      sign_in host
      get "/conversations/#{conversation.id}/report"
    end

    it 'redirects to the conversation' do
      expect(response).to redirect_to(conversation_path(conversation))
    end

    it 'shows a specific flash message' do
      expect(flash[:notice]).to eq('The report was recorded! Someone will analyze this conversation shortly.')
    end

    it 'sends the email notification' do
      expect(ConversationMailer).to have_received(:inappropriate_content)
      expect(mail).to have_received(:deliver_later)
    end
  end
end
