# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomPolicy do
  subject { described_class }

  let(:youth) { create(:user, :youth) }
  let(:host) { create(:user, :host, :approved) }
  let(:social_worker) { create(:user, :social_worker) }
  let(:room) { create(:room, :with_valid_parameters) }

  context 'when user is a host' do
    it { is_expected.to permit(host, host.rooms, :my?) }

    context 'when room is hidden' do
      let(:room) { create(:room, :with_valid_parameters, hidden: true, user: host) }
      let(:other_host) { create(:user, :host, :approved) }

      it { is_expected.to permit(host, room, :show?) }
      it { is_expected.not_to permit(other_host, room, :show?) }
    end

    context 'when user is a host who created the room' do
      let(:room) { create(:room, :with_valid_parameters, user: host) }

      it { is_expected.not_to permit(host, room, :dashboard?) }
      it { is_expected.to permit(host, room, :index?) }
      it { is_expected.to permit(host, room, :show?) }
      it { is_expected.to permit(host, room, :edit?) }
      it { is_expected.to permit(host, room, :update?) }
      it { is_expected.to permit(host, room, :new?) }
      it { is_expected.to permit(host, room, :create?) }
      it { is_expected.not_to permit(host, room, :destroy?) }
      it { is_expected.to permit(host, room, :hide?) }
      it { is_expected.to permit(host, room, :unhide?) }
    end

    context 'when user is the host who did not create the room' do
      it { is_expected.not_to permit(host, room, :dashboard?) }
      it { is_expected.to permit(host, room, :index?) }
      it { is_expected.to permit(host, room, :show?) }
      it { is_expected.not_to permit(host, room, :edit?) }
      it { is_expected.not_to permit(host, room, :update?) }
      it { is_expected.to permit(host, room, :new?) }
      it { is_expected.to permit(host, room, :create?) }
      it { is_expected.not_to permit(host, room, :destroy?) }
      it { is_expected.not_to permit(host, room, :hide?) }
      it { is_expected.not_to permit(host, room, :unhide?) }
    end
  end

  context 'when the user is a youth' do
    it { is_expected.not_to permit(youth, youth.rooms, :my?) }

    context 'when the user is not approved' do
      it { is_expected.not_to permit(youth, room, :dashboard?) }
      it { is_expected.to permit(youth, room, :index?) }
      it { is_expected.not_to permit(youth, room, :edit?) }
      it { is_expected.to permit(youth, room, :show?) }
      it { is_expected.not_to permit(youth, room, :update?) }
      it { is_expected.not_to permit(youth, room, :new?) }
      it { is_expected.not_to permit(youth, room, :create?) }
      it { is_expected.not_to permit(youth, room, :destroy?) }
      it { is_expected.not_to permit(youth, room, :hide?) }
      it { is_expected.not_to permit(youth, room, :unhide?) }
    end

    context 'when room is hidden' do
      let(:youth) { create(:user, :youth, approved: true) }
      let(:room) { create(:room, :with_valid_parameters, hidden: true) }

      it { is_expected.not_to permit(youth, room, :show?) }
    end

    context 'when the user is approved' do
      let(:youth) { create(:user, :youth, approved: true) }

      it { is_expected.not_to permit(youth, room, :dashboard?) }
      it { is_expected.to permit(youth, room, :index?) }
      it { is_expected.to permit(youth, room, :show?) }
      it { is_expected.not_to permit(youth, room, :edit?) }
      it { is_expected.not_to permit(youth, room, :update?) }
      it { is_expected.not_to permit(youth, room, :new?) }
      it { is_expected.not_to permit(youth, room, :create?) }
      it { is_expected.not_to permit(youth, room, :destroy?) }
      it { is_expected.not_to permit(youth, room, :hide?) }
      it { is_expected.not_to permit(youth, room, :unhide?) }
    end
  end

  context 'when the user is a social worker' do
    it { is_expected.not_to permit(social_worker, social_worker.rooms, :my?) }
    it { is_expected.not_to permit(social_worker, room, :dashboard?) }
    it { is_expected.to permit(social_worker, room, :index?) }
    it { is_expected.to permit(social_worker, room, :show?) }
    it { is_expected.not_to permit(social_worker, room, :edit?) }
    it { is_expected.not_to permit(social_worker, room, :update?) }
    it { is_expected.not_to permit(social_worker, room, :new?) }
    it { is_expected.not_to permit(social_worker, room, :create?) }
    it { is_expected.not_to permit(social_worker, room, :destroy?) }
    it { is_expected.not_to permit(social_worker, room, :hide?) }
    it { is_expected.not_to permit(social_worker, room, :unhide?) }
  end
end
