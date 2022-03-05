# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Admin::Types::Dropdown do
  let(:section) { double }
  let(:property) do
    {
      field_name: :field,
      field_type: :dropdown,
      options:    { values: [] }
    }
  end
  let(:described_obj) { described_class.new(section, property) }
  let(:field) { double }

  before do
    allow(section).to receive(:field) do |_property, _type, &block|
      field.instance_eval(&block)
    end
  end

  describe '#form' do
    before do
      allow(described_obj).to receive(:visibility)
      allow(field).to receive(:enum).and_yield
      allow(field).to receive(:multiple)
      described_obj.form
    end

    it 'uses correct field type' do
      expect(section).to have_received(:field).with(:field, :enum)
    end

    it 'sets up visibility' do
      expect(described_obj).to have_received(:visibility)
    end

    context 'with enum setup' do
      it 'passes values to field' do
        expect(field).to have_received(:enum) do |&block|
          expect(field.instance_eval(&block)).to eq(property[:options][:values])
        end
      end
    end

    context 'when single dropdown' do
      it 'configures multiple as false' do
        expect(field).to have_received(:multiple).with(be_falsey)
      end
    end

    context 'when multiple dropdown' do
      let(:property) do
        {
          field_name: :field,
          field_type: :dropdown,
          options:    { values: [], multiple: true }
        }
      end

      it 'configures multiple as true' do
        expect(field).to have_received(:multiple).with(true)
      end
    end
  end

  describe '#show' do
    before do
      allow(described_obj).to receive(:visibility)
      allow(described_obj).to receive(:pretty_value)
      allow(field).to receive(:value)
      allow(field).to receive(:pretty_value) do |&block|
        field.instance_eval(&block)
      end
      described_obj.show
    end

    it 'sets up field visibility' do
      expect(described_obj).to have_received(:visibility).with(field)
    end

    it 'sets up pretty_value' do
      expect(described_obj).to have_received(:pretty_value)
    end
  end

  describe '#pretty_value' do
    let(:value) { Faker::Lorem.words }

    context 'when dropdown single' do
      it 'returns unchanged value' do
        expect(described_obj.pretty_value(value)).to eq(value)
      end
    end

    context 'when dropdown multiple' do
      before do
        property[:options][:multiple] = true
      end

      it 'returns joined value' do
        expect(described_obj.pretty_value(value)).to eq(value.join(', '))
      end
    end
  end
end
