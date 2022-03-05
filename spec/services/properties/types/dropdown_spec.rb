# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Types::Dropdown do
  let(:model_class) { double }
  let(:value) { double }

  context 'with single element dropdown' do
    let(:property) { { field_name: :field_name } }

    describe '#serialize' do
      it 'returns simple value' do
        expect(described_class.new(property, model_class).serialize(value)).to eq(value)
      end
    end

    describe '#deserialize' do
      it 'returns simple value' do
        expect(described_class.new(property, model_class).deserialize(value)).to eq(value)
      end
    end
  end

  context 'with multiple elements dropdown' do
    let(:property) { { field_name: :field_name, options: { multiple: true } } }

    describe '#serialize' do
      it 'returns array value' do
        expect(described_class.new(property, model_class).serialize(value)).to be_a(Array)
        expect(described_class.new(property, model_class).serialize(value)).to eq([value])
      end
    end

    describe '#deserialize' do
      it 'returns array value' do
        expect(described_class.new(property, model_class).deserialize(value)).to be_a(Array)
        expect(described_class.new(property, model_class).deserialize(value)).to eq([value])
      end
    end
  end
end
