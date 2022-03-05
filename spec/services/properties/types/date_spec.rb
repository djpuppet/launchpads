# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Types::Date do
  let(:model_class) { double }
  let(:property) { { field_name: :field_name } }

  describe '#serialize' do
    it 'returns string value' do
      expect(described_class.new(property, model_class).serialize(Time.zone.today)).to eq(Time.zone.today.to_s)
      expect(described_class.new(property, model_class).serialize(nil)).to be_nil
    end
  end

  describe '#deserialize' do
    it 'returns Date value' do
      expect(described_class.new(property, model_class).deserialize(Time.zone.today.to_s)).to eq(Time.zone.today)
      expect(described_class.new(property, model_class).deserialize(nil)).to be_nil
    end
  end
end
