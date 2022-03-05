# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/FilePath
RSpec.describe RailsAdmin::Extensions::PunditNamespaced::AuthorizationAdapter do
  let(:controller) { double }
  let(:described_obj) { described_class.new(controller, :admin) }
  let(:record) { User }
  let(:user) { create(:user, :admin) }
  let(:policy) { double }
  let(:abstract_model) { OpenStruct.new(model: record) }

  before do
    allow(controller).to receive(:pundit_user).and_return(user)
  end

  context 'when namespaced policy found' do
    before do
      allow(controller).to receive(:policy).and_return(policy)
      allow(controller).to receive(:policy_scope).and_return(record.all)
      allow(policy).to receive(:new?).and_return(true)
    end

    it 'executes policy method with array argument' do
      described_obj.authorize(:new, nil, record)
      expect(controller).to have_received(:policy).with([:admin, record])
      expect(controller).not_to have_received(:policy).with(record)
    end

    it 'uses namespaced scope in query' do
      described_obj.query(nil, abstract_model)
      expect(controller).to have_received(:policy_scope).with([:admin, record.all])
      expect(controller).not_to have_received(:policy_scope).with(record.all)
    end
  end

  context 'when namespaced policy not found' do
    let(:application_policy) do
      policy = double
      allow(policy).to receive(:new?).and_return(true)
      policy
    end

    before do
      allow(controller).to receive(:policy).and_raise(Pundit::NotDefinedError)
      allow(controller).to receive(:policy_scope).and_raise(Pundit::NotDefinedError)
      allow(::ApplicationPolicy).to receive(:new).and_return(application_policy)
    end

    it 'uses parent\'s #policy' do
      described_obj.authorize(:new, nil, record)
      expect(controller).to have_received(:policy).with(record)
    end

    it 'uses parent\'s #query' do
      described_obj.query(nil, abstract_model)
      expect(controller).to have_received(:policy_scope).with(record.all)
    end
  end
end
# rubocop:enable RSpec/FilePath
