# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Options do
  let(:value) { Faker::Lorem.word }
  let(:proc_argument) { proc { value } }
  let(:argument) { value }

  describe '#[]' do
    context 'when key is a proc' do
      let(:object) { described_class.new(proc_argument) }

      it 'returns result of proc' do
        expect(object[:value].class).to eq(Proc)
        expect(object[:value].call).to eq(value)
      end
    end

    context 'when key is not a proc' do
      let(:object) { described_class.new(argument) }

      it 'returns value from key' do
        expect(object[:value]).to eq(value)
      end
    end
  end
end
