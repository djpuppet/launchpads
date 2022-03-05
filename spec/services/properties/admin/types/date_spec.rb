# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Admin::Types::Date do
  let(:section) { double }
  let(:property) do
    {
      field_name: :field,
      field_type: :date,
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
    let(:value) { nil }

    before do
      allow(described_obj).to receive(:visibility)
      allow(field).to receive(:value).and_return(value)
      allow(field).to receive(:formatted_value).and_yield
      allow(I18n).to receive(:l)
      described_obj.form
    end

    it 'uses correct field type' do
      expect(section).to have_received(:field).with(:field, :date)
    end

    it 'sets up visibility' do
      expect(described_obj).to have_received(:visibility)
    end

    context 'when value present' do
      let(:value) { Time.zone.today }

      it 'formats values' do
        expect(I18n).to have_received(:l).with(value, format: :long)
      end
    end

    context 'when value blank' do
      before do
        allow(field).to receive(:value).and_return(nil)
      end

      it 'does nothing' do
        expect(field).to have_received(:formatted_value)
        expect(I18n).not_to have_received(:l).with(value, format: :long)
      end
    end
  end

  describe '#show' do
    before do
      allow(described_obj).to receive(:form)
    end

    it 'uses the same setup as #form' do
      described_obj.show

      expect(described_obj).to have_received(:form)
    end
  end
end
