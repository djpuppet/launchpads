# frozen_string_literal: true

class ConversationUser < ApplicationRecord
  belongs_to :conversation, inverse_of: :conversation_users
  belongs_to :user, inverse_of: :conversation_users

  validates :conversation, presence: true
  validates :user, presence: true
  validates :user_id, uniqueness: { scope: :conversation_id }

  validate :validate_roles_uniqueness, if: -> { user.present? }
  validate :validate_participants_no, if: -> { user.present? }

  private

  def validate_participants_no
    return unless conversation

    users = conversation.users | [user]
    errors.add(:base, :participants_no) if users.size > 3
  end

  def validate_roles_uniqueness
    users = conversation.users | [user]
    roles = users.map(&:role)
    validate_basic_roles(users, roles)
    validate_social_worker(users, roles)
  end

  def validate_basic_roles(users, roles)
    errors.add(:base, :roles_uniqueness) unless users.size < 2 || (%w[host youth] - roles).empty?
  end

  # :reek:FeatureEnvy
  def validate_social_worker(users, roles)
    return if users.size < 3

    errors.add(:base, :roles_uniqueness) unless roles.include?('social_worker') || roles.include?('admin')
  end
end
