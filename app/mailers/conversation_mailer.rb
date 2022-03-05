# frozen_string_literal: true

class ConversationMailer < ApplicationMailer
  def inappropriate_content(conversation)
    @url = conversation_url(conversation)
    mail(to: ENV['ADMIN_EMAIL'], subject: 'Inappropriate content')
  end

  private

  def conversation_url(conversation)
    RailsAdmin::Engine.routes.url_helpers.show_url('conversation', conversation)
  end
end
