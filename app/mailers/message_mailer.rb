# frozen_string_literal: true

class MessageMailer < ApplicationMailer
  def create_message(users, conversation)
    @conversation = conversation
    mail(to: users.pluck(:email), subject: 'You got a new message on Launchpads!')
  end
end
