# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Admin::Types::Roommates do
  let(:section) { double }
  let(:property) do
    {
      field_name: :field,
      field_type: :roommates,
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
      allow(field).to receive(:partial)
      described_obj.form
    end

    it 'uses correct field type' do
      expect(section).to have_received(:field).with(:field)
    end

    it 'sets up visibility' do
      expect(described_obj).to have_received(:visibility)
    end

    it 'defines correct partial' do
      expect(field).to have_received(:partial).with('roommates-list-form')
    end
  end

  describe '#show' do
    let(:view) { double }
    let(:bindings) do
      {
        view: view
      }
    end

    before do
      allow(described_obj).to receive(:visibility)
      allow(field).to receive(:pretty_value).and_yield
      allow(field).to receive(:bindings).and_return(bindings)
      allow(field).to receive(:value)
      allow(view).to receive(:render)
      described_obj.show
    end

    it 'uses correct field type' do
      expect(section).to have_received(:field).with(:field)
    end

    it 'sets up visibility' do
      expect(described_obj).to have_received(:visibility)
    end

    it 'sets up pretty_value' do
      expect(field).to have_received(:pretty_value)
      expect(view).to have_received(:render).with(partial: 'roommates-list-preview', locals: Hash)
    end
  end
end
