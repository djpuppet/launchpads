# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :admin_redirect, except: %i[show]
  before_action :fetch_user, only: %i[show]
  before_action :setup_user, only: %i[edit update validate]

  def show; end

  def preview
    @user = authorize(current_user)
  end

  def edit; end

  def update_password
    @user = authorize(current_user)

    if @user.update_with_password(password_update_params)
      bypass_sign_in(@user)
      render body: '', status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_update_params)
      notify_completed_profile
      render :update
    else
      flash[:error] = 'You cannot submit this without completing all required fields'
      render :edit, status: :unprocessable_entity
    end
  end

  def validate
    @user.assign_attributes(user_validate_params)
    if @user.valid?
      render :edit, status: :ok
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def select_type
    authorize current_user
    user_role = current_user.role
    redirect_to(root_path) && return if current_user.admin?

    redirect_to edit_profile_path(user_role) if user_role
  end

  def redirect_to_profile_form
    authorize current_user
    role = params[:type]
    if User::PROFILES.keys.include?(role.try(:to_sym))
      redirect_to(edit_profile_path(type: role))
    else
      flash[:error] = 'You cannot submit this without completing all required fields'
      render :select_type, status: :unprocessable_entity
    end
  end

  private

  def user_update_params
    role = params[:type].to_sym
    params.require(:user).permit(policy(User).update_params(role)).reverse_merge(photos: [])
  end

  def password_update_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def user_validate_params
    Attachments::Base.validation_props(user_update_params, %i[photos])
  end

  def setup_user
    @user = authorize current_user
    return if @user.role.present?

    type = params[:type]
    redirect_to profile_type_path unless type.present? || (type == 'admin' && !current_user.admin?)
    @user.role = type
  end

  def fetch_user
    @user = authorize policy_scope(User).find(params[:id])
  end

  def admin_redirect
    redirect_to(root_path) if current_user&.admin?
  end

  def notify_completed_profile
    ProfileMailer.complete_profile(current_user).deliver_later unless current_user.approved?
    if current_user.youth?
      notify_social_worker
    else
      ProfileMailer.complete_profile_to_approval(current_user).deliver_later
    end
  end

  def notify_social_worker
    social_worker = current_user.social_worker
    ProfileMailer.complete_profile_to_survey(current_user, social_worker).deliver_later if social_worker_related
  end

  def social_worker_related
    current_user.social_worker && current_user.social_worker_id_previously_changed?
  end
end
