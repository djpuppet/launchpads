# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageMailer, type: :mailer do
  let(:conversation) { create(:conversation, :with_messages) }
  let(:users) { conversation.users }

  describe 'create message' do
    let(:mail) { described_class.create_message(users, conversation) }

    it 'renders the headers' do
      expect(mail.subject).to eq('You got a new message on Launchpads!')
      expect(mail.to).to eq(users.pluck(:email))
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("#{ENV['APP_HOST']}/conversations/#{conversation.id}")
    end
  end
end
