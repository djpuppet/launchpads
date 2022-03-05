# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfilesController, type: :request do
  describe '#show' do
    let(:youth) { create(:user, :youth, :with_valid_parameters) }

    it 'has status 200' do
      sign_in youth

      get "/profile/#{youth.id}"
      expect(response.status).to eq(200)
    end
  end

  describe '#edit' do
    let(:profile) { User::PROFILES.keys.sample }

    context 'when a user is not logged in' do
      it 'redirects a user to root' do
        get "/profile/#{profile}"
        expect(response.status).to eq(302)
        expect(response).to redirect_to('/')
        expect(flash).to be_key(:turbolinks_redirect)
      end
    end

    context 'when redirect for unauthorized request' do
      before do
        get "/profile/#{profile}"
        get '/'
      end

      it 'includes Turbolinks-Location header after redirect' do
        expect(response.headers['Turbolinks-Location']).to eq(root_path)
      end

      it 'expect location flash to be removed' do
        expect(flash).not_to be_key(:turbolinks_redirect)
      end
    end

    context 'when a user is logged in' do
      let(:user) { create(:user) }
      let(:youth) { create(:user, :youth) }

      context "when user hasn't a role" do
        it 'has proper param in params' do
          sign_in user

          get "/profile/#{profile}"
          expect(response.status).to eq(200)
          expect(controller.params[:type]).to eq(profile.to_s)
        end
      end

      context 'when user has a role' do
        it 'has proper type in params' do
          sign_in youth

          get "/profile/#{youth.role}"
          expect(response.status).to eq(200)
          expect(controller.params[:type]).to eq(youth.role)
        end
      end
    end
  end

  describe '#update' do
    let(:user) { create(:user, :youth) }
    let(:profile) { user.role }
    let(:invalid_param) { Faker::Lorem.word }
    let(:mail_message) { double }
    let(:mail_to_sw) { double }
    let(:mail_to_admin) { double }

    before do
      sign_in user
      allow(ProfileMailer).to receive(:complete_profile).and_return(mail_message)
      allow(mail_message).to receive(:deliver_later)
      allow(ProfileMailer).to receive(:complete_profile_to_survey).and_return(mail_to_sw)
      allow(mail_to_sw).to receive(:deliver_later)
      allow(ProfileMailer).to receive(:complete_profile_to_approval).and_return(mail_to_admin)
      allow(mail_to_admin).to receive(:deliver_later)
    end

    context 'when user is invalid' do
      before do
        post "/profile/#{profile}", params: { user: { gender: invalid_param } }
      end

      it 'does not update a user' do
        expect(flash[:error]).to eq('You cannot submit this without completing all required fields')
        expect(user).not_to be_valid
      end

      it "doesn't send an email message to youth" do
        expect(ProfileMailer).not_to have_received(:complete_profile)
        expect(mail_message).not_to have_received(:deliver_later)
      end

      it "doesn't send an email message to social_worker" do
        expect(ProfileMailer).not_to have_received(:complete_profile_to_survey)
        expect(mail_to_sw).not_to have_received(:deliver_later)
      end

      it "doesn't send an email message to admin" do
        expect(ProfileMailer).not_to have_received(:complete_profile_to_approval)
        expect(mail_to_admin).not_to have_received(:deliver_later)
      end
    end

    context 'when user is valid' do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, :youth, :with_valid_parameters) }

      before do
        sign_in user
        post '/profile/youth', params: { user: params }
      end

      it 'updates a user' do
        expect(user).to be_valid
      end

      it 'sends an email message about the completed profile to youth' do
        expect(ProfileMailer).to have_received(:complete_profile)
        expect(mail_message).to have_received(:deliver_later)
      end

      it "sends an email message about the youth's completed profile to social worker" do
        expect(ProfileMailer).to have_received(:complete_profile_to_survey)
        expect(mail_to_sw).to have_received(:deliver_later)
      end

      it "doesn't send an email message to admin" do
        expect(ProfileMailer).not_to have_received(:complete_profile_to_approval)
        expect(mail_to_admin).not_to have_received(:deliver_later)
      end
    end

    context 'when the user is valid and has a different role than youth' do
      let(:role) { (User::ROLES.keys - %i[youth admin]).sample }
      let(:user) { create(:user, role) }
      let(:params) { attributes_for(:user, role, :with_valid_parameters) }

      before do
        post "/profile/#{role}", params: { user: params }
      end

      it 'updates a user' do
        expect(user).to be_valid
      end

      it 'sends an email message about the completed profile to user' do
        expect(ProfileMailer).to have_received(:complete_profile)
        expect(mail_message).to have_received(:deliver_later)
      end

      it "doesn't send an email message to social_worker" do
        expect(ProfileMailer).not_to have_received(:complete_profile_to_survey)
        expect(mail_to_sw).not_to have_received(:deliver_later)
      end

      it 'sends an email message to admin to approve the new user' do
        expect(ProfileMailer).to have_received(:complete_profile_to_approval)
        expect(mail_to_admin).to have_received(:deliver_later)
      end
    end

    context 'when admin role is passed by non-admin' do
      let(:params) { attributes_for(:user, :youth, :with_valid_parameters) }

      it 'redirects to profile type selection page' do
        expect { post '/profile/admin', params: { user: params } }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe '#validate' do
    let(:user) { create(:user, :youth) }
    let(:profile) { user.role }
    let(:invalid_param) { Faker::Lorem.word }

    before { sign_in user }

    context 'when user is invalid' do
      it 'responds with status 422' do
        post "/profile/#{profile}/validate", params: { user: { gender: invalid_param } }
        expect(response.status).to eq(422)
      end
    end

    context 'when user is valid' do
      let(:params) { attributes_for(:user, :youth, :with_valid_parameters) }

      it 'responds with status 200' do
        post "/profile/#{profile}/validate", params: { user: params }
        expect(response.status).to eq(200)
      end
    end
  end

  describe '#select_type' do
    let(:user) { create(:user) }
    let(:youth) { create(:user, :youth) }

    context 'when a user has no role set' do
      it 'redirects to profile type path' do
        sign_in user

        get '/profile'
        expect(response.body).to include('Select your user type')
      end
    end

    context 'when a user has role' do
      it 'redirects to profile type path' do
        sign_in youth

        get '/profile'
        expect(response).to redirect_to("/profile/#{youth.role}")
      end
    end
  end

  describe '#redirect_to_profile_form' do
    let(:user) { create(:user) }

    before { sign_in user }

    context 'when the url has wrong role in params' do
      let(:params) do
        { type: Faker::Lorem.word }
      end

      it 'renders select type template' do
        post '/profile', params: params

        expect(response.status).to eq(422)
        expect(flash[:error]).to eq('You cannot submit this without completing all required fields')
        expect(response.body).to include('Select your user type')
      end
    end

    context 'when the url has proper role in params' do
      let(:profile) { User::PROFILES.keys.sample }
      let(:params) do
        { type: profile }
      end

      it 'redirects to edit profile path' do
        puts profile
        post '/profile', params: params

        expect(response.status).to eq(302)
        expect(response).to redirect_to("/profile/#{profile}")
      end
    end
  end
end
