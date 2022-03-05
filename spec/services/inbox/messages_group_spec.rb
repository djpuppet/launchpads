# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inbox::MessagesGroup do
  let(:is_odd) { [true, false].sample }
  let(:date_changed) { [true, false].sample }
  let(:messages) { Array.new(2, double) }
  let(:described_obj) { described_class.new(is_odd, date_changed) }

  it 'initializes with passed flags values' do
    expect(described_obj.odd?).to eq(is_odd)
    expect(described_obj.date_changed).to eq(date_changed)
  end

  describe '#add_message' do
    it 'appends message to the end of the messages list' do
      described_obj.add_message(messages[0])
      described_obj.add_message(messages[1])

      expect(described_obj.messages).to eq(messages)
    end
  end
end
