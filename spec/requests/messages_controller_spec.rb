# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :request do
  describe '#create' do
    let(:youth) { create(:user, :youth, :with_valid_parameters, :approved) }
    let(:host) { create(:user, :host, :with_valid_parameters, :approved) }
    let(:social_worker) { create(:user, :social_worker, :with_valid_parameters, :approved) }
    let(:conversation) { create(:conversation, users: [youth, host]) }
    let(:content) { Faker::Lorem.sentence }
    let(:message) { double }

    before do
      sign_in youth
      allow(MessageMailer).to receive(:create_message).and_return(message)
      allow(message).to receive(:deliver_later)
    end

    it 'redirects to the conversation' do
      post "/conversations/#{conversation.id}/messages", params: { message: { content: content } }
      expect(response).to redirect_to("/conversations/#{conversation.id}")
    end

    it 'creates the new message' do
      post "/conversations/#{conversation.id}/messages", params: { message: { content: content } }
      expect(conversation.messages.last.content).to eq(content)
    end

    context 'when all users have read messages' do
      it 'sends notification to all recipients' do
        post "/conversations/#{conversation.id}/messages", params: { message: { content: content } }
        expect(MessageMailer).to have_received(:create_message).with([host], conversation)
        expect(message).to have_received(:deliver_later)
      end
    end

    context 'when social worker has been invited to the conversation' do
      let(:conversation) { create(:conversation, users: [youth, host, social_worker]) }

      it 'sends notification to both users' do
        post "/conversations/#{conversation.id}/messages", params: { message: { content: content } }
        expect(MessageMailer).to have_received(:create_message).with([host, social_worker], conversation)
        expect(message).to have_received(:deliver_later)
      end
    end

    context 'when one of the recipients has marked the conversation as ignored' do
      let(:conversation) { create(:conversation, users: [youth, host, social_worker]) }

      before do
        conversation.conversation_users.find_by(user: social_worker).update(ignored: true)
        conversation.conversation_users.each { |u| u.update(read: true) }
      end

      it 'sends notification to the only one recipient' do
        post "/conversations/#{conversation.id}/messages", params: { message: { content: content } }
        expect(MessageMailer).to have_received(:create_message).with([host], conversation)
        expect(message).to have_received(:deliver_later)
      end
    end
  end
end
