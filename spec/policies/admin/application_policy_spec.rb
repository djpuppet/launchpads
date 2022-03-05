# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ApplicationPolicy do
  subject { described_class }

  let(:record) { double }
  let(:youth) { create(:user, :youth) }
  let(:host) { create(:user, :host) }
  let(:social_worker) { create(:user, :social_worker) }
  let(:admin) { create(:user, :admin) }

  context 'when current user is an admin' do
    it { is_expected.to permit(admin, record, :dashboard?) }
    it { is_expected.to permit(admin, record, :index?) }
    it { is_expected.to permit(admin, record, :show?) }
    it { is_expected.to permit(admin, record, :edit?) }
    it { is_expected.to permit(admin, record, :update?) }
    it { is_expected.to permit(admin, record, :new?) }
    it { is_expected.to permit(admin, record, :create?) }
    it { is_expected.to permit(admin, record, :destroy?) }
    it { is_expected.to permit(admin, record, :export?) }
    it { is_expected.not_to permit(admin, record, :show_in_app?) }
  end

  context 'when current user is an youth' do
    it { is_expected.not_to permit(youth, record, :dashboard?) }
    it { is_expected.not_to permit(youth, record, :index?) }
    it { is_expected.not_to permit(youth, record, :show?) }
    it { is_expected.not_to permit(youth, record, :edit?) }
    it { is_expected.not_to permit(youth, record, :update?) }
    it { is_expected.not_to permit(youth, record, :new?) }
    it { is_expected.not_to permit(youth, record, :create?) }
    it { is_expected.not_to permit(youth, record, :destroy?) }
    it { is_expected.not_to permit(youth, record, :export?) }
    it { is_expected.not_to permit(youth, record, :show_in_app?) }
  end

  context 'when current user is a social worker' do
    it { is_expected.not_to permit(social_worker, record, :dashboard?) }
    it { is_expected.not_to permit(social_worker, record, :index?) }
    it { is_expected.not_to permit(social_worker, record, :show?) }
    it { is_expected.not_to permit(social_worker, record, :edit?) }
    it { is_expected.not_to permit(social_worker, record, :update?) }
    it { is_expected.not_to permit(social_worker, record, :new?) }
    it { is_expected.not_to permit(social_worker, record, :create?) }
    it { is_expected.not_to permit(social_worker, record, :destroy?) }
    it { is_expected.not_to permit(social_worker, record, :export?) }
    it { is_expected.not_to permit(social_worker, record, :show_in_app?) }
  end

  context 'when current user is a host' do
    it { is_expected.not_to permit(host, record, :dashboard?) }
    it { is_expected.not_to permit(host, record, :index?) }
    it { is_expected.not_to permit(host, record, :show?) }
    it { is_expected.not_to permit(host, record, :edit?) }
    it { is_expected.not_to permit(host, record, :update?) }
    it { is_expected.not_to permit(host, record, :new?) }
    it { is_expected.not_to permit(host, record, :create?) }
    it { is_expected.not_to permit(host, record, :destroy?) }
    it { is_expected.not_to permit(host, record, :export?) }
    it { is_expected.not_to permit(host, record, :show_in_app?) }
  end
end
