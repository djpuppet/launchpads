# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inbox::MessageAnalyzer do
  let(:message) { create(:message) }
  let(:previous_author_id) { nil }
  let(:previous_date) { nil }
  let(:previous_alignment) { false }
  let(:described_obj) do
    described_class.new(
      message,
      {
        author_id: previous_author_id,
        date:      previous_date,
        odd:       previous_alignment
      }
    )
  end

  describe '#new' do
    let(:previous_author_id) { Faker::Number.rand(100) }
    let(:previous_date) { Faker::Date.backward(days: rand(100)) }
    let(:previous_alignment) { [true, false].sample }

    it 'stores author_id' do
      expect(described_obj.analysis.author_id).to eq(previous_author_id)
    end

    it 'stores date' do
      expect(described_obj.analysis.date).to eq(previous_date)
    end

    it 'stores alignment' do
      expect(described_obj.analysis.odd?).to eq(previous_alignment)
    end
  end

  context 'when author changes' do
    let(:previous_author_id) { message.user.id + 1 }

    before do
      described_obj.analyze
    end

    context 'when date changes' do
      let(:previous_date) { message.created_at.to_date - 1.day }

      it 'changes alignment' do
        expect(described_obj.analysis).to be_odd
      end

      it 'changes author_id' do
        expect(described_obj.analysis.author_id).to eq(message.user.id)
      end

      it 'changes date_changed flag' do
        expect(described_obj.analysis.date_changed).to be_truthy
      end
    end

    context 'when date is the same' do
      let(:previous_date) { message.created_at.to_date }

      it 'changes alignment' do
        expect(described_obj.analysis).to be_odd
      end

      it 'changes author_id' do
        expect(described_obj.analysis.author_id).to eq(message.user.id)
      end

      it 'leaves date_changed flag unchanged' do
        expect(described_obj.analysis.date_changed).to be_falsey
      end
    end
  end

  context 'when author is the same' do
    let(:previous_author_id) { message.user.id }

    before do
      described_obj.analyze
    end

    context 'when date changes' do
      let(:previous_date) { message.created_at.to_date - 1.day }

      it 'leaves alignment unchanged' do
        expect(described_obj.analysis).not_to be_odd
      end

      it 'leaves author_id unchanged' do
        expect(described_obj.analysis.author_id).to eq(message.user.id)
      end

      it 'changes date_changed flag' do
        expect(described_obj.analysis.date_changed).to be_truthy
      end
    end

    context 'when date is the same' do
      let(:previous_date) { message.created_at.to_date }

      it 'leaves alignment unchanged' do
        expect(described_obj.analysis).not_to be_odd
      end

      it 'leaves author_id unchanged' do
        expect(described_obj.analysis.author_id).to eq(message.user.id)
      end

      it 'leaves date_changed flag unchanged' do
        expect(described_obj.analysis.date_changed).to be_falsey
      end
    end
  end

  describe 'Result' do
    let(:author_id) { double }
    let(:date) { double }
    let(:is_odd) { false }
    let(:date_changed) { double }

    let(:object) do
      described_class::Result.new(
        author_id:    author_id,
        date:         date,
        odd:          is_odd,
        date_changed: date_changed
      )
    end

    it 'stores all props' do
      expect(object.index).to be_zero
      expect(object.author_id).to eq(author_id)
      expect(object.date).to eq(date)
      expect(object.odd?).to eq(is_odd)
      expect(object.date_changed).to eq(date_changed)
    end

    it 'switched alignment' do
      object.switch_alignment
      expect(object).to be_odd
      object.switch_alignment
      expect(object).not_to be_odd
    end

    it 'updates author_id' do
      new_id = Faker::Number.rand
      object.update_author_id(new_id)
      expect(object.author_id).to eq(new_id)
    end

    it 'updates date' do
      new_date = Faker::Date.forward
      object.update_date(new_date)
      expect(object.date).to eq(new_date)
    end

    it 'increments index' do
      expect { object.increment_index }.to change(object, :index).by(1)
    end
  end
end
