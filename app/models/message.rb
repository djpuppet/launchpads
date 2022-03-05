# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :conversation, touch: true
  belongs_to :user

  after_save -> { conversation.conversation_users.where.not(user: user).update(read: false) }

  scope :with_users, -> { merge(User.with_photos) }
  scope :newest, -> { order(created_at: :desc) }

  validates :content, presence: true
end
