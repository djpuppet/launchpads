# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :fetch_conversation, only: %i[create]

  def create
    active_participants = fetch_active_recipients
    message = authorize @conversation.messages.build(message_params.merge(user: current_user))
    notify(active_participants) if message.save

    redirect_to(@conversation, only_path: true)
  end

  private

  def notify(recipients)
    MessageMailer.create_message(recipients, @conversation).deliver_later if recipients.any?
  end

  def fetch_active_recipients
    @conversation.conversation_users.where(read: true, ignored: false).where.not(user_id: current_user.id).map(&:user)
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def fetch_conversation
    @conversation = policy_scope(Conversation).find(params[:conversation_id])
  end
end
