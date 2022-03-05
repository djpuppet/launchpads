# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :fetch_conversation, only: %i[show ignore unignore invite_social_worker report]

  def index
    @conversations = authorize(
      policy_scope(Conversation)
        .joins(:messages) # only load conversations with messages
        .with_associations
        .order(updated_at: :desc)
    )
  end

  def find_or_create
    fetch_users
    find_or_create_conversation

    if @conversation.persisted?
      redirect_to conversation_path(@conversation)
    else
      skip_authorization
      redirect_to root_path, notice: 'Could not create the conversation with this user!'
    end
  end

  def show
    @conversation.read!(current_user)
  end

  def ignore
    @conversation.ignore!(current_user)

    redirect_to(conversations_path, notice: 'Conversation is muted')
  end

  def unignore
    @conversation.unignore!(current_user)

    redirect_to(conversations_path, notice: 'Conversation is not muted anymore')
  end

  def invite_social_worker
    social_worker = @conversation.find_social_worker
    if social_worker
      @conversation.users << social_worker
      flash[:notice] = 'Social worker was invited to the conversation'
    else
      flash[:notice] = 'Social worker could not be found!'
    end

    redirect_to(conversation_path(@conversation))
  end

  def report
    ConversationMailer.inappropriate_content(@conversation).deliver_later
    flash[:notice] = 'The report was recorded! Someone will analyze this conversation shortly.'
    redirect_to(conversation_path(@conversation))
  end

  private

  def find_or_create_conversation
    @conversation = policy_scope(Conversation).with_participants(@users).first
    @conversation = Conversation.create(users: @users) if @conversation.blank?

    authorize(@conversation)
  end

  def fetch_conversation
    @conversation = policy_scope(Conversation)
                    .with_associations
                    .find(params[:id])
    authorize @conversation
  end

  def fetch_users
    @users = [current_user, find_recipient]
  end

  def find_recipient
    User.find(params[:user_id])
  end
end
