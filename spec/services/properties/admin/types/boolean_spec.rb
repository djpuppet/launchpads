# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Admin::Types::Boolean do
  let(:section) { double }
  let(:property) do
    {
      field_name: :field,
      field_type: :boolean,
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
    end

    it 'uses correct field type' do
      described_obj.form

      expect(section).to have_received(:field).with(:field, :boolean)
    end

    it 'sets up field visibility' do
      described_obj.form

      expect(described_obj).to have_received(:visibility).with(field)
    end
  end

  describe '#show' do
    before do
      allow(described_obj).to receive(:form)
    end

    it 'sets up field visibility' do
      described_obj.show

      expect(described_obj).to have_received(:form)
    end
  end
end
