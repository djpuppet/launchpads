# frozen_string_literal: true

Room.all[2..].map(&:destroy)

photos = Room.first.photos.map(&:blob)
1.upto(200) do |index|
  FactoryBot.create(:room, :with_valid_parameters, photos: photos)
  Rails.logger.debug "Room #{index} created"
end
