# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Admin::EditField do
  let(:section) { double }
  let(:described_obj) { described_class.new(section, property) }
  let(:handler) { double }
  let(:handler_instance) { double }

  describe '#call' do
    context 'when property has supported type' do
      let(:property) do
        {
          field_type: :boolean
        }
      end

      before do
        allow(handler).to receive(:new).and_return(handler_instance)
        allow(handler_instance).to receive(:form)
        stub_const('Properties::Admin::Types::Boolean', handler)
      end

      it 'instantiates and call proper handler' do
        described_obj.call
        expect(handler).to have_received(:new)
        expect(handler_instance).to have_received(:form)
      end
    end

    context 'when property has unsupported type' do
      let(:property) do
        {
          field_type: :unsupported
        }
      end

      before do
        allow(handler).to receive(:new).and_return(handler_instance)
        allow(handler_instance).to receive(:form)
        stub_const('Properties::Admin::Types::Generic', handler)
      end

      it 'instantiates and call generic handler' do
        described_obj.call
        expect(handler).to have_received(:new)
        expect(handler_instance).to have_received(:form)
      end
    end
  end
end
