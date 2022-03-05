# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConversationMailer, type: :mailer do
  let(:conversation) { create(:conversation) }

  describe 'inappropriate_content' do
    let(:mail) { described_class.inappropriate_content(conversation) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Inappropriate content')
      expect(mail.to).to eq([ENV['ADMIN_EMAIL']])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("#{ENV['APP_HOST']}/admin/conversation/#{conversation.id}")
    end
  end
end
