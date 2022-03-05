# frozen_string_literal: true

# :reek:MissingSafeMethod { exclude: [ read!, ignore!, unignore! ] }
class Conversation < ApplicationRecord
  include ConversationAdmin

  has_many :messages, dependent: :destroy
  has_many :conversation_users, dependent: :destroy
  has_many :users, through: :conversation_users, autosave: false

  validate :validate_participants

  scope :with_associations, lambda {
    includes(:messages, :conversation_users, :users)
      .merge(Message.with_users.order(updated_at: :asc))
  }

  def self.with_participants(users)
    where(id: with_exact_participants(users))
  end

  def self.with_exact_participants(users)
    users_size = users.size
    ConversationUser
      .select(:conversation_id)
      .where(conversation_id: with_participants_no(users_size), user: users)
      .group(:conversation_id)
      .having('count(id) = ?', users_size)
  end

  def self.with_participants_no(size)
    ConversationUser.group(:conversation_id).having('count(id) = ?', size).select(:conversation_id)
  end

  def find_social_worker
    users.detect(&:youth?)&.social_worker
  end

  def includes_social_worker?
    users.detect(&:social_worker?).present?
  end

  def includes_youth?
    users.detect(&:youth?).present?
  end

  def read_by?(user)
    find_user_relation(user).read?
  end

  def ignored_by?(user)
    find_user_relation(user).ignored?
  end

  def read!(user)
    find_user_relation(user)&.update(read: true)
  end

  def ignore!(user)
    find_user_relation(user)&.update(ignored: true)
  end

  def unignore!(user)
    find_user_relation(user)&.update(ignored: false)
  end

  private

  def find_user_relation(user)
    conversation_users.detect { |item| item.user_id == user.id }
  end

  def validate_participants
    users_size = users.size
    errors.add(:users, :invalid) if users_size < 2 || users_size > 3
  end
end
