# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# :reek:MissingSafeMethod { exclude: [ hide!, unhide! ] }
class Room < ApplicationRecord
  include RoomAdmin

  belongs_to :user
  alias host user
  has_many_attached :photos

  PROPERTY_VALUES       = ['single family home', 'multi-unit home/duplex', 'apartment', 'in-law unit', 'other'].freeze
  ROOM_VALUES           = [
    'single room', 'single room with separate entrance', 'in-law unit', 'private', 'other'
  ].freeze
  AMENITIES_VALUES      = ['laundry', 'close to pt', 'parking available', 'walkable neighborhood', 'wifi'].freeze
  SMOKING_VAPING_VALUES = %w[inside outside no].freeze
  SMOKING_TYPE_VALUES   = %w[thc tobacco].freeze
  PET_FRIENDLY_VALUES   = %w[cats dogs other].freeze
  CHILDREN_VALUES       = %w[yes no possibly].freeze
  CITY_VALUES           = %w[sf oakland berkeley el_cerrito richmond alameda emeryville san_leandro daly_city south_sf
                             millbrae other].freeze
  MAXIMUM_ROOM_RATE     = 1500

  extend WithProperties

  # step 1
  property :title, :text
  property :city, :dropdown, { options: { values: CITY_VALUES } }
  property :other_city, :text
  property :move_in_date, :date
  property :duration_of_stay, :range
  property :rent, :currency
  property :utilities, :currency
  property :property_type, :dropdown, { options: { values: PROPERTY_VALUES } }
  property :room_type, :dropdown, { options: { values: ROOM_VALUES } }
  property :furnished, :boolean
  # step 2
  property :about, :text
  property :amenities, :dropdown, options: { multiple: true, values: AMENITIES_VALUES }
  property :other_amenities, :text
  property :rules, :text
  # step 3
  property :smoking, :dropdown, options: { values: SMOKING_VAPING_VALUES }
  property :vaping, :dropdown, options: { values: SMOKING_VAPING_VALUES }
  property :smoking_types, :dropdown, options: { multiple: true, values: SMOKING_TYPE_VALUES }
  property :pet_friendly, :dropdown, options: { multiple: true, values: PET_FRIENDLY_VALUES }
  property :accept_children, :dropdown, options: { values: CHILDREN_VALUES }

  # step 1
  validates :title, presence: true
  validates :city,
            inclusion:         { in: CITY_VALUES },
            presence_or_other: true,
            allow_blank:       false
  validates :move_in_date, presence: true
  validates :duration_of_stay, presence: true
  validates :rent, presence: true, numericality: { greater_than: 0 }
  validates :property_type, inclusion: { in: PROPERTY_VALUES }
  validates :room_type, inclusion: { in: ROOM_VALUES }
  validates :furnished, inclusion: { in: [true, false] }
  # step 2
  validates :about, presence: true
  # step 3
  validates :smoking, inclusion: { in: SMOKING_VAPING_VALUES }, allow_blank: true
  validates :vaping, inclusion: { in: SMOKING_VAPING_VALUES }, allow_blank: true
  validates :accept_children, inclusion: { in: CHILDREN_VALUES }

  validate :rent_with_utilities_value
  validate :correct_amenities_types
  validate :correct_smoking_types
  validate :correct_pet_friendly_types

  scope :with_photos, -> { includes(photos_attachments: :blob).merge(User.with_photos) }

  scope :max_price, lambda { |max|
    where("(rooms.properties ->> 'rent')::NUMERIC + (rooms.properties ->> 'utilities')::NUMERIC <= ?", max)
  }
  scope :duration_of_stay, ->(duration) { where("(rooms.properties ->> 'duration_of_stay')::NUMERIC >= ?", duration) }
  scope :children_friendly, -> { where("(rooms.properties ->> 'accept_children') = 'yes'") }
  scope :pet_friendly, -> { where("NOT (rooms.properties ->> 'pet_friendly')::jsonb = '[]'::jsonb") }
  scope :no_smoking, -> { where("(rooms.properties ->> 'smoking') = 'no'") }
  scope :from_cities, ->(cities) { where("(rooms.properties ->> 'city') IN (?)", cities) }

  scope :featured, -> { visible.order(featured: :desc, id: :desc).limit(3) }
  scope :available, -> { includes(:user).where(users: { approved: true }) }
  scope :visible, -> { available.where(hidden: false) }

  def full_price
    return rent + utilities if utilities

    rent
  end

  def hide!
    update(hidden: true)
  end

  def unhide!
    update(hidden: false)
  end

  def owned_by?(user)
    host == user
  end

  def city_or_other_city
    city == 'other' ? other_city : city
  end

  def accept_children?
    accept_children == 'yes'
  end

  def possibly_accept_children?
    accept_children == 'possibly'
  end

  private

  def rent_with_utilities_value
    return true if rent + utilities <= MAXIMUM_ROOM_RATE

    errors.add(:rent, " + Utilities can't be greater than #{MAXIMUM_ROOM_RATE} combined")
    errors.add(:utilities, " + Rent can't be greater than #{MAXIMUM_ROOM_RATE} combined")
  end

  def correct_amenities_types
    validates_multiple_inclusion(:amenities, AMENITIES_VALUES)
  end

  def correct_pet_friendly_types
    validates_multiple_inclusion(:pet_friendly, PET_FRIENDLY_VALUES)
  end

  def correct_smoking_types
    validates_multiple_inclusion(:smoking_types, SMOKING_TYPE_VALUES)
  end
end
# rubocop:enable Metrics/ClassLength
