# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inbox::Constructor do
  let(:conversation) { create(:conversation, :with_messages) }
  let(:described_obj) { described_class.new(conversation.messages) }
  let(:analyzer) { double }
  let(:author_ids) { Array.new(conversation.messages.size) { |i| i % 2 + 1 } }
  let(:analysis) { double }

  before do
    allow(Inbox::MessageAnalyzer).to receive(:new).and_return(analyzer)
    allow(analyzer).to receive(:analyze)
    allow(analyzer).to receive(:analysis).and_return(analysis)
    allow(analysis).to receive(:author_id).and_return(*author_ids)
    allow(analysis).to receive(:odd?).and_return(false)
    allow(analysis).to receive(:index).and_return(0)
    allow(analysis).to receive(:date).and_return(Time.zone.today)
    allow(analysis).to receive(:date_changed).and_return(false)
  end

  context 'when each message is a separate group' do
    before do
      allow(analysis).to receive(:index).and_return(0, 1)
    end

    it 'returns array with length equal to messages count' do
      expect(described_obj.call.size).to eq(conversation.messages.size)
    end
  end

  context 'when some messages are grouped' do
    let(:indexes) { Array.new(conversation.messages.size) { |i| i % 2 } }

    before do
      allow(analysis).to receive(:index).and_return(*indexes)
    end

    it 'returns array with length equal to messages count / 2' do
      expect(described_obj.call.size).to eq((conversation.messages.size / 2.0).ceil)
    end
  end

  context 'when date changes' do
    before do
      allow(analysis).to receive(:date_changed).and_return(true)
    end

    it 'marks each group with new date flag' do
      groups = described_obj.call
      expect(groups).to be_all(&:date_changed)
    end
  end
end
