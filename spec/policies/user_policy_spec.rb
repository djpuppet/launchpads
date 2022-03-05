# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }

  let(:host) { create(:user, :host) }
  let(:social_worker) { create(:user, :social_worker) }
  let(:user) { create(:user, :youth) }

  context 'when user manages himself' do
    it { is_expected.not_to permit(user, user, :dashboard?) }
    it { is_expected.not_to permit(user, user, :index?) }
    it { is_expected.to permit(user, user, :show?) }
    it { is_expected.to permit(user, user, :edit?) }
    it { is_expected.to permit(user, user, :update?) }
    it { is_expected.not_to permit(user, user, :new?) }
    it { is_expected.not_to permit(user, user, :create?) }
    it { is_expected.not_to permit(user, user, :destroy?) }
    it { is_expected.to permit(user, user, :select_type?) }
    it { is_expected.to permit(user, user, :validate?) }
    it { is_expected.to permit(user, user, :redirect_to_profile_form?) }
    it { is_expected.to permit(user, user, :update_password?) }
  end

  context 'when user is a host' do
    it { is_expected.not_to permit(host, user, :dashboard?) }
    it { is_expected.not_to permit(host, user, :index?) }
    it { is_expected.to permit(host, user, :show?) }
    it { is_expected.not_to permit(host, user, :edit?) }
    it { is_expected.not_to permit(host, user, :update?) }
    it { is_expected.not_to permit(host, user, :new?) }
    it { is_expected.not_to permit(host, user, :create?) }
    it { is_expected.not_to permit(host, user, :destroy?) }
    it { is_expected.not_to permit(host, user, :select_type?) }
    it { is_expected.not_to permit(host, user, :validate?) }
    it { is_expected.not_to permit(host, user, :redirect_to_profile_form?) }
    it { is_expected.not_to permit(host, user, :update_password?) }
  end

  context 'when user is a social_worker' do
    it { is_expected.not_to permit(social_worker, user, :dashboard?) }
    it { is_expected.not_to permit(social_worker, user, :index?) }
    it { is_expected.to permit(social_worker, user, :show?) }
    it { is_expected.not_to permit(social_worker, user, :edit?) }
    it { is_expected.not_to permit(social_worker, user, :update?) }
    it { is_expected.not_to permit(social_worker, user, :new?) }
    it { is_expected.not_to permit(social_worker, user, :create?) }
    it { is_expected.not_to permit(social_worker, user, :destroy?) }
    it { is_expected.not_to permit(social_worker, user, :select_type?) }
    it { is_expected.not_to permit(social_worker, user, :validate?) }
    it { is_expected.not_to permit(social_worker, user, :redirect_to_profile_form?) }
    it { is_expected.not_to permit(social_worker, user, :update_password?) }
  end

  describe 'Scope' do
    context 'when user is a host' do
      let(:host) { create(:user, :host, :with_valid_parameters, :approved) }
      let(:youth) { create(:user, :youth, :with_valid_parameters, :approved) }

      context 'when there is not any conversations between host and youth' do
        it 'returns an array with only host' do
          expect(Pundit.policy_scope(host, User)).to match_array([host])
        end
      end

      context 'when there is a conversation between host and youth' do
        let(:other_host) { create(:user, :host, :with_valid_parameters, :approved) }

        before do
          create(:conversation, users: [host, youth])
          create(:conversation, users: [other_host, youth])
        end

        it 'returns an array with youth and hosts' do
          expect(Pundit.policy_scope(host, User)).to match_array([host, other_host, youth])
        end
      end
    end

    context 'when user is a youth' do
      let(:youth) { create(:user, :youth, :with_valid_parameters) }

      it 'returns an array with himself' do
        expect(Pundit.policy_scope(youth, User)).to match_array([youth])
      end
    end

    context 'when user is a social_worker' do
      let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }
      let(:youth) { create(:user, :youth, :with_valid_parameters, social_worker: social_worker) }

      before do
        create_list(:user, 2, :youth, :with_valid_parameters)
      end

      it 'returns an array with youth' do
        expect(Pundit.policy_scope(social_worker, User)).to match_array([youth])
      end
    end
  end
end
