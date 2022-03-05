# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Types::Currency do
  let(:model_class) { double }
  let(:property) { { field_name: :field_name } }

  describe '#serialize' do
    it 'returns float value' do
      expect(described_class.new(property, model_class).serialize(0)).to be_a(Float)
      expect(described_class.new(property, model_class).serialize('0')).to be_a(Float)
      expect(described_class.new(property, model_class).serialize(nil)).to be_a(Float)
    end
  end

  describe '#deserialize' do
    it 'returns float value' do
      expect(described_class.new(property, model_class).deserialize(0)).to be_a(Float)
      expect(described_class.new(property, model_class).deserialize('0')).to be_a(Float)
      expect(described_class.new(property, model_class).deserialize(nil)).to be_a(Float)
    end
  end
end
