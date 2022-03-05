# frozen_string_literal: true

class ApprovalSurvey
  def initialize(survey)
    @survey = survey
    @result = OpenStruct.new(success: nil, valid: nil)
  end

  def self.call(survey)
    new(survey).call
  end

  def call
    handle_conditions
    handle_record
    @result
  end

  private

  def handle_record
    return unless @result.valid && @result.success

    @survey.save
    handle_user unless @survey.details_required?
  end

  def handle_conditions
    values_for_existing_survey && return if @survey.persisted?

    values_for_new_survey
  end

  def values_for_existing_survey
    @result.success = @survey.valid?
    @result.valid = @survey.valid?(:initial)
  end

  def values_for_new_survey
    @result.valid = @result.success = @survey.valid?
  end

  def handle_user
    user = @survey.user
    user.update(approved: true)
    ProfileMailer.approved_user(user).deliver_later
  end
end
