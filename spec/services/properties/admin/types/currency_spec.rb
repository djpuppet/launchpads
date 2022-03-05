# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Admin::Types::Currency do
  let(:section) { double }
  let(:property) do
    {
      field_name: :field,
      field_type: :currency,
      roles:      %i[role]
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
      allow(described_obj).to receive(:html_attributes)
    end

    it 'uses correct field type' do
      described_obj.form

      expect(section).to have_received(:field).with(:field, :decimal)
    end

    it 'sets up field visibility' do
      described_obj.form

      expect(described_obj).to have_received(:visibility).with(field)
    end

    it 'sets up html attributes' do
      described_obj.form

      expect(described_obj).to have_received(:html_attributes).with(field)
    end
  end

  describe '#show' do
    before do
      allow(described_obj).to receive(:visibility)
    end

    it 'sets up field visibility' do
      described_obj.show

      expect(described_obj).to have_received(:visibility).with(field)
    end
  end

  describe '#html_attributes' do
    let(:correct_setup) do
      {
        required: true,
        type:     :number,
        step:     0.01
      }
    end

    before do
      allow(field).to receive(:html_attributes) do |&block|
        field.instance_eval(&block)
      end
      allow(field).to receive(:required?).and_return(correct_setup[:required])
    end

    it 'calls field.html_attributes with correct setup' do
      expect(described_obj.html_attributes(field)).to match(correct_setup)
      expect(field).to have_received(:html_attributes)
      expect(field).to have_received(:required?)
    end
  end
end
