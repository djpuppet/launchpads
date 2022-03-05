# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SurveysController, type: :request do
  let(:social_worker) { create(:user, :social_worker, :with_valid_parameters, :approved) }

  describe '#index' do
    it 'returns status 200' do
      sign_in social_worker
      get '/surveys'
      expect(response.status).to eq(200)
    end
  end

  describe '#fill' do
    context 'when user is related with social_worker' do
      let(:user) { create(:user, :youth, :with_valid_parameters, social_worker: social_worker) }

      it 'returns status 200' do
        sign_in social_worker
        get "/surveys/fill/#{user.id}"

        expect(response.status).to eq(200)
      end
    end

    context 'when user is not related with social_worker' do
      let(:user) { create(:user, :youth, :with_valid_parameters) }

      before do
        sign_in social_worker
        get "/surveys/fill/#{user.id}"
      end

      it 'redirects to the root path' do
        expect(response.status).to eq(302)
        expect(response).to redirect_to('/')
      end

      it 'presents proper flash message' do
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end
  end

  describe '#details' do
    context 'when user is related with social_worker' do
      let(:user) { create(:user, :youth, :with_valid_parameters, social_worker: social_worker) }

      it 'returns status 200' do
        sign_in social_worker
        get "/surveys/details/#{user.id}"

        expect(response.status).to eq(200)
      end
    end

    context 'when user is not related with social_worker' do
      let(:user) { create(:user, :youth, :with_valid_parameters) }

      before do
        sign_in social_worker
        get "/surveys/details/#{user.id}"
      end

      it 'redirects to the root path' do
        expect(response.status).to eq(302)
        expect(response).to redirect_to('/')
      end

      it 'presents proper flash message' do
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end
  end

  describe '#save' do
    let(:user) { create(:user, :youth, :with_valid_parameters, social_worker: social_worker) }
    let(:mail) { double }
    let(:mail_to_analysis) { double }

    before do
      allow(SurveyMailer).to receive(:new_survey_for_analysis).and_return(mail_to_analysis)
      allow(SurveyMailer).to receive(:youth_approved).and_return(mail)
      allow(SurveyMailer).to receive(:complete_survey).and_return(mail)
      allow(mail_to_analysis).to receive(:deliver_later)
      allow(mail).to receive(:deliver_later)
    end

    context 'when survey is a new record' do
      context 'when attributes are missing' do
        let(:survey_params) { { good_candidate: nil, silp_assesment_completed: nil, user: user } }

        it 'renders fill' do
          sign_in social_worker
          post "/surveys/save/#{user.id}", params: { survey: survey_params }
          expect(response.body).to include('General Questions')
        end
      end

      context 'when youth is not related with social worker' do
        let(:sw) { create(:user, :social_worker, :with_valid_parameters, :approved) }
        let(:survey_params) { attributes_for(:survey) }

        it "doesn't give an access to menage it" do
          sign_in sw
          post "/surveys/save/#{user.id}", params: { survey: survey_params }
          expect(response).to redirect_to('/')
          expect(flash[:alert]).to eq('You are not authorized to perform this action.')
        end
      end

      context 'when got affirmative answers' do
        let(:survey_params) { attributes_for(:survey, good_candidate: '1', silp_assesment_completed: '1') }

        before do
          sign_in social_worker
          post "/surveys/save/#{user.id}", params: { survey: survey_params }
        end

        it 'approves user' do
          user.reload
          expect(user.approved).to be_truthy
        end

        it 'redirects to the users list' do
          expect(response.body).to include('User was successfully approved')
        end

        it 'sends the notification about completing the survey' do
          expect(SurveyMailer).to have_received(:youth_approved)
          expect(mail).to have_received(:deliver_later)
        end

        it "doesn't send the notification about the survey to analysis" do
          expect(SurveyMailer).not_to have_received(:new_survey_for_analysis)
          expect(mail_to_analysis).not_to have_received(:deliver_later)
        end
      end

      context 'when answers are negative' do
        let(:survey_params) { attributes_for(:survey, good_candidate: '0', silp_assesment_completed: '0') }

        before do
          sign_in social_worker
          post "/surveys/save/#{user.id}", params: { survey: survey_params.merge(step: 'initial') }
        end

        it "doesn't approve user" do
          user.reload
          expect(user.approved).to be_falsey
        end

        it 'redirects to the details form' do
          expect(response).to redirect_to(details_surveys_path(user))
        end

        it "doesn't send the notification about completing the survey" do
          expect(SurveyMailer).not_to have_received(:youth_approved)
          expect(mail).not_to have_received(:deliver_later)
        end

        it 'does not send the notification about the survey to analysis' do
          expect(SurveyMailer).not_to have_received(:new_survey_for_analysis)
          expect(mail_to_analysis).not_to have_received(:deliver_later)
        end
      end
    end

    context 'when survey is an existing record and it needs to fill up details' do
      before do
        create(:survey, good_candidate: '0', silp_assesment_completed: '1', user: user)
        sign_in social_worker
        post "/surveys/save/#{user.id}", params: { survey: survey_params.merge(step: 'details') }
      end

      context 'when receive valid attributes' do
        let(:survey_params) do
          attributes_for(:survey,
                         :with_details,
                         good_candidate:           '0',
                         silp_assesment_completed: '1')
        end

        it 'shows a message about waiting for approval by the admin' do
          expect(response.body).to include('The user is pending on acceptance by admin.')
        end

        it 'sends the notification about completing the survey' do
          expect(SurveyMailer).to have_received(:complete_survey)
          expect(mail).to have_received(:deliver_later)
        end

        it 'sends the notification about the survey to analysis' do
          expect(SurveyMailer).to have_received(:new_survey_for_analysis)
          expect(mail_to_analysis).to have_received(:deliver_later)
        end

        context 'when receive invalid attributes' do
          let(:survey_params) do
            attributes_for(:survey,
                           good_candidate:           '0',
                           silp_assesment_completed: '1')
          end

          it 'renders :details' do
            sign_in social_worker
            post "/surveys/save/#{user.id}", params: { survey: survey_params.merge(step: 'details') }
            expect(response.body).to include('Survey Questions')
          end
        end
      end
    end
  end
end
