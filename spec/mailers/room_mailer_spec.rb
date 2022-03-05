# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomMailer, type: :mailer do
  let(:room) { create(:room, :with_valid_parameters) }

  describe 'create_room' do
    let(:mail) { described_class.create_room(room) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Thanks for creating a listing on Launchpads!')
      expect(mail.to).to eq([room.user.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(room_url(room))
      expect(mail.body.encoded).to match("Hi #{room.user.first_name},")
    end
  end
end
