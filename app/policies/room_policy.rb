# frozen_string_literal: true

class RoomPolicy < ApplicationPolicy
  PERMITTED_PARAMS = [
    :title, :city, :other_city, :move_in_date, :duration_of_stay, :rent, :utilities, :property_type, :room_type, :about,
    :amenities, :other_amenities, :smoking, :vaping, :accept_children, :rules, :furnished,
    { amenities: [], pet_friendly: [], smoking_types: [], photos: [] }
  ].freeze

  def index?
    true
  end

  def new?
    user&.host?
  end

  def create?
    user&.host?
  end

  def show?
    record.owned_by?(user) || !record.hidden?
  end

  def edit?
    user&.host? && record.owned_by?(user)
  end

  def update?
    user&.host? && record.owned_by?(user)
  end

  def validate?
    record.new_record? || record.owned_by?(user)
  end

  def my?
    user&.host?
  end

  def hide?
    can_control_visibility?
  end

  def unhide?
    can_control_visibility?
  end

  private

  def can_control_visibility?
    user&.host? && record.owned_by?(user)
  end

  class OwnedRoomsScope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  class Scope < Scope
    def resolve
      scope.visible
    end
  end
end
