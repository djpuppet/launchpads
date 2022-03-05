# frozen_string_literal: true

require 'rails_helper'

class Model
  def properties; end
end

RSpec.describe Properties::Types::Generic do
  let(:model_class) { double }
  let(:property) { { field_name: :field_name } }

  describe '#call' do
    before do
      allow(model_class).to receive(:define_method)
    end

    it 'defines getter and setter' do
      described_class.new(property, model_class).call
      expect(model_class).to have_received(:define_method).with(/^field_name=$/)
      expect(model_class).to have_received(:define_method).with(/^field_name$/)
    end
  end

  describe '#serialize' do
    let(:value) { double }

    it 'returns unmodified value' do
      expect(described_class.new(property, model_class).serialize(value)).to eq(value)
    end
  end

  describe '#deserialize' do
    let(:value) { double }

    it 'returns unmodified value' do
      expect(described_class.new(property, model_class).deserialize(value)).to eq(value)
    end
  end

  describe '#getter' do
    let(:properties_hash) { double }
    let(:model_class) { Model }
    let(:described_obj) { described_class.new(property, model_class) }

    before do
      allow(properties_hash).to receive(:fetch).and_return(nil)
      allow_any_instance_of(model_class).to receive(:properties).and_return(properties_hash)
      allow(described_obj).to receive(:deserialize).and_call_original
      described_obj.call
    end

    it 'uses instance variable if already set' do
      model = model_class.new
      model.field_name = Faker::Lorem.word
      expect(model.field_name).not_to be_nil
      expect(properties_hash).not_to have_received(:fetch)
    end

    it 'uses properties hash if instance variable not used' do
      model = model_class.new
      expect(model.field_name).to be_nil
      expect(properties_hash).to have_received(:fetch)
    end

    it 'call deserialize' do
      model = model_class.new
      model.field_name
      expect(described_obj).to have_received(:deserialize)
    end
  end

  describe '#setter' do
    let(:model_class) { Model }
    let(:described_obj) { described_class.new(property, model_class) }

    before do
      described_obj.call
    end

    it 'creates instance variable' do
      model = model_class.new
      model.field_name = Faker::Lorem.word
      expect(model).to be_instance_variable_defined('@field_name')
    end
  end
end
