# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Admin::Types::Generic do
  let(:section) { double }
  let(:property) do
    {
      field_name: :field,
      field_type: :generic,
      roles:      %i[role]
    }
  end
  let(:described_obj) { described_class.new(section, property) }
  let(:field) { double }
  let(:bindings) do
    {
      object: OpenStruct.new(role: 'role')
    }
  end

  before do
    allow(field).to receive(:bindings).and_return(bindings)
    allow(section).to receive(:field) do |_property, _type, &block|
      field.instance_eval(&block)
    end
  end

  describe '#form' do
    before do
      allow(described_obj).to receive(:visibility)
    end

    it 'sets up field visibility' do
      described_obj.form

      expect(section).to have_received(:field).with(:field)
      expect(described_obj).to have_received(:visibility).with(field)
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

  describe '#visibility' do
    before do
      allow(field).to receive(:visible) do |&block|
        field.instance_eval(&block)
      end
    end

    context 'when user has certain role' do
      it 'is enables visibility' do
        expect(described_obj.visibility(field)).to be_truthy
        expect(field).to have_received(:visible)
      end
    end

    context 'when user doesn\'t have certain role' do
      before do
        property[:roles] = %i[not_matching]
      end

      it 'is disables visibility' do
        expect(described_obj.visibility(field)).to be_falsey
        expect(field).to have_received(:visible)
      end
    end

    context 'when property does not support roles' do
      before do
        property[:roles] = nil
      end

      it 'is enables visibility' do
        expect(described_obj.visibility(field)).to be_truthy
        expect(field).to have_received(:visible)
      end
    end
  end
end
