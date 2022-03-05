# frozen_string_literal: true

class RoomMailer < ApplicationMailer
  def create_room(room)
    @room = room
    mail(to: room.user.email, subject: 'Thanks for creating a listing on Launchpads!')
  end
end
