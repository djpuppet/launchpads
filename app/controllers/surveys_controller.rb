# frozen_string_literal: true

# :reek:TooManyInstanceVariables { max_instance_variables: 5 }
class SurveysController < ApplicationController
  before_action :fetch_user, only: %i[fill save details]
  before_action :fetch_survey, only: %i[fill save details]

  def index
    authorize Survey
    @filters = UserFilters.new(filter_params)
    @users = paginate(filtered_youths, 15)
  end

  def fill; end

  # :reek:DuplicateMethodCall { max_calls: 2 }
  def save
    @survey.assign_attributes(survey_params)
    state = ApprovalSurvey.call(@survey)
    return handle_success if state.valid && state.success

    if state.valid
      @survey.valid?(:details)
      return render(:details)
    end

    render :fill
  end

  def details; end

  private

  def handle_success
    notify
    set_message
    if @survey.details_required? && initial_step?
      flash[:notice] = @message if @message.present?
      redirect_to(details_surveys_path(@survey.user)) && return
    end

    @continue_path = surveys_path
    render :success
  end

  def set_message
    if @survey.user.approved?
      @message = I18n.t('users.create.notice.approved')
    elsif details_step?
      @message = I18n.t('users.create.notice.pending')
    end
  end

  def fetch_user
    @user = policy_scope(User).find_by(id: params[:user_id])
  end

  def fetch_survey
    @survey = authorize Survey.find_or_initialize_by(user: @user)
  end

  def filter_params
    params.fetch(:user_filters, {}).permit(UserFilters.attribute_names)
  end

  def survey_params
    params.require(:survey).permit(SurveyPolicy::PERMITTED_PARAMS)
  end

  # :reek:DuplicateMethodCall { max_calls: 2 }
  def filtered_youths
    scope = policy_scope(User).with_photos

    scope = scope.with_status(@filters.status) if @filters.filter_with_status?
    scope = scope.ordered(@filters.sort_by) if @filters.sort_by
    scope = scope.by_keyword(@filters.keyword) if @filters.keyword

    scope
  end

  def initial_step?
    params[:survey][:step] == 'initial'
  end

  def details_step?
    params[:survey][:step] == 'details'
  end

  def notify
    if @user.approved?
      SurveyMailer.youth_approved(@survey.user).deliver_later
    elsif details_step?
      SurveyMailer.complete_survey(current_user, @survey).deliver_later
      SurveyMailer.new_survey_for_analysis(@survey).deliver_later
    end
  end
end
