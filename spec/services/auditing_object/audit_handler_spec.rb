# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditingObject::AuditHandler, type: :service do
  let(:described_obj) { described_class.new }
  let(:args) { double }
  let(:action) { double }
  let(:model) { double }
  let(:object) { double }
  let(:model_name) { Faker::Lorem.word }

  before do
    allow(args).to receive(:[]).with(:model).and_return(model)
    allow(model).to receive(:model_name).and_return(model_name)
    allow(object).to receive(:send)
  end

  describe '#call' do
    context 'when the handler class exists' do
      let(:constantize_class) { double }

      before do
        allow(constantize_class).to receive(:new).and_return(object)
        allow(Module).to receive(:const_defined?).and_return(true)
        allow(Module).to receive(:const_get).and_return(constantize_class)
        described_obj.call(action, args)
      end

      it 'executes proper methods during the flow' do
        expect(Module).to have_received(:const_defined?)
        expect(constantize_class).to have_received(:new)
        expect(object).to have_received(:send)
      end
    end

    context "when the handler class doesn't exist" do
      before do
        allow(Module).to receive(:const_defined?).and_return(false)
        allow(AuditingObject::Handlers::Base).to receive(:new).and_return(object)
        described_obj.call(action, args)
      end

      it 'executes proper methods during the flow' do
        expect(Module).to have_received(:const_defined?)
        expect(AuditingObject::Handlers::Base).to have_received(:new)
        expect(object).to have_received(:send)
      end
    end
  end
end
