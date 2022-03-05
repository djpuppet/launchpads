# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Types::Boolean do
  let(:model_class) { double }
  let(:property) { { field_name: :field_name } }

  describe '#serialize' do
    let(:value) { ActiveRecord::Type::Boolean::FALSE_VALUES.to_a.sample }

    it 'returns boolean value' do
      expect(described_class.new(property, model_class).serialize(value)).to be_falsey
      expect(described_class.new(property, model_class).serialize(true)).to be_truthy
      expect(described_class.new(property, model_class).serialize('1')).to be_truthy
      expect(described_class.new(property, model_class).serialize(1)).to be_truthy
    end

    it 'returns nil for empty string' do
      expect(described_class.new(property, model_class).serialize('')).to be_nil
    end
  end
end
