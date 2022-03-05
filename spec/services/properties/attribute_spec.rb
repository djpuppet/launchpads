# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Attribute do
  describe '#call' do
    let(:property) do
      {
        field_type: :defined_type
      }
    end
    let(:handler) { double }

    context 'when type is defined' do
      before do
        stub_const('Properties::Types::DefinedType', handler)
        allow(handler).to receive(:new).and_return(handler)
        allow(handler).to receive(:call)
      end

      it 'calls a specific type handler' do
        described_class.new(property, double).call
        expect(handler).to have_received(:new)
        expect(handler).to have_received(:call)
      end
    end

    context 'when type is not defined' do
      before do
        stub_const('Properties::Types::Generic', handler)
        allow(handler).to receive(:new).and_return(handler)
        allow(handler).to receive(:call)
      end

      it 'calls Generic type handler' do
        described_class.new(property, double).call
        expect(handler).to have_received(:new)
        expect(handler).to have_received(:call)
      end
    end
  end
end
