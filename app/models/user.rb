# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# :reek:TooManyConstants
class User < ApplicationRecord
  extend Enumerize
  include UserAdmin

  PROFILES             = { social_worker: 1, host: 2, youth: 3 }.freeze
  ROLES                = { admin: 0 }.merge(PROFILES).freeze
  BENEFITS_VALUES      = %w[food_vouchers cash_aid medical ssi phi wic other].freeze
  GENDER_VALUES        = %w[male female non_binary not_to_respond other].freeze
  TRANSGENDER_VALUES   = %w[yes no not_to_respond].freeze
  PRONOUNS_VALUES      = %w[he she they not_to_respond other].freeze
  ETHNICITIES_VALUES   = %w[white black asian latin native not_to_respond other].freeze
  LGBT_FRIENDLY_VALUES = %w[yes no unsure].freeze
  EMAIL_REGEXP         = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/.freeze
  PHONE_REGEXP         = /\A\d{10}\z/.freeze

  enumerize :role, in: ROLES, default: nil, predicates: true, scope: true

  extend WithProperties

  # step 1
  property :first_name, :text, { roles: %i[youth host social_worker] }
  property :last_name, :text, { roles: %i[youth host social_worker] }
  property :username, :text, { roles: %i[youth host] }
  property :social_worker_unlisted, :boolean, { roles: %i[youth] }
  property :phone, :text, { roles: %i[youth host] }
  property :dob, :date, { roles: %i[youth host] }
  property :phone, :text, { roles: %i[youth host] }
  property :benefits, :dropdown, {
    options: { multiple: true, values: BENEFITS_VALUES },
    roles:   %i[youth]
  }
  property :other_benefits, :text, { roles: %i[youth] }
  property :gender, :dropdown, {
    options: {
      values: GENDER_VALUES
    },
    roles:   %i[youth host]
  }
  property :other_gender, :text, { roles: %i[youth host] }
  property :transgender, :dropdown, {
    options: {
      values: TRANSGENDER_VALUES
    },
    roles:   %i[youth host]
  }
  property :pronouns, :dropdown, {
    options: {
      values: PRONOUNS_VALUES
    },
    roles:   %i[youth host]
  }
  property :other_pronouns, :text, { roles: %i[youth host] }
  property :ethnicities, :dropdown, {
    options: { multiple: true, values: ETHNICITIES_VALUES },
    roles:   %i[youth host]
  }
  property :other_ethnicity, :text, { roles: %i[youth host] }
  property :show_gender, :boolean, { roles: %i[youth host] }
  property :show_pronouns, :boolean, { roles: %i[youth host] }
  property :show_transgender, :boolean, { roles: %i[youth host] }
  property :show_ethnicity, :boolean, { roles: %i[youth host] }
  # step 2
  property :about, :text, { roles: %i[youth host] }
  property :education, :text, { roles: %i[youth] }
  property :school, :text, { roles: %i[youth] }
  property :work, :text, { roles: %i[youth] }
  property :language, :text, { roles: %i[host] }
  property :lgbt_friendly, :dropdown, {
    options: { multiple: false, values: LGBT_FRIENDLY_VALUES },
    roles:   %i[host]
  }
  # step 3
  property :children, :text, { roles: %i[youth] }
  property :visible_messages_agreement, :boolean, { roles: %i[youth host] }

  # step 1
  property_validates :first_name, presence: true, allow_blank: false, on: :update
  property_validates :last_name, presence: true, allow_blank: false, on: :update
  property_validates :username, presence: true, allow_blank: false, on: :update
  property_validates :phone, presence: true, allow_blank: false, on: :update
  property_validates :dob, presence: true, allow_blank: false, on: :update
  property_validates :about, presence: true, allow_blank: false, on: :update
  property_validates :gender,
                     inclusion:         { in: GENDER_VALUES },
                     presence_or_other: true,
                     allow_blank:       false,
                     on:                :update
  property_validates :transgender,
                     inclusion:   { in: TRANSGENDER_VALUES },
                     allow_blank: false,
                     on:          :update
  property_validates :pronouns,
                     inclusion:         { in: PRONOUNS_VALUES },
                     presence_or_other: true,
                     on:                :update
  property_validates :show_gender, inclusion: { in: [true, false] }, on: :update
  property_validates :show_pronouns, inclusion: { in: [true, false] }, on: :update
  property_validates :show_transgender, inclusion: { in: [true, false] }, on: :update
  property_validates :show_ethnicity, inclusion: { in: [true, false] }, on: :update
  property_validates :lgbt_friendly, inclusion: { in: LGBT_FRIENDLY_VALUES }, on: :update

  # step 3
  property_validates :children, numericality: true, on: :update
  property_validates :ethnicities, presence: true, allow_blank: false, on: :update
  property_validate :ethnicities, :correct_ethnicity_types
  property_validate :benefits, :correct_benefit_types
  property_validate :social_worker_unlisted, :social_worker_selected
  property_validate :phone, :phone_format, on: :update
  property_validates :visible_messages_agreement, acceptance: { message: 'must be accepted' }, on: :update

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :agreements_acceptance, acceptance: { presence: true }
  validates :email, uniqueness: true, presence: true, format: { with: EMAIL_REGEXP }

  has_one :survey, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :conversation_users, dependent: :destroy
  has_many :conversations, through: :conversation_users
  has_many_attached :photos
  has_many :youths, class_name: 'User', inverse_of: :social_worker, foreign_key: :social_worker_id, dependent: :nullify
  belongs_to :social_worker, class_name: 'User', optional: true

  scope :with_photos, -> { includes(photos_attachments: :blob) }
  scope :approved, -> { where(approved: true) }
  scope :unapproved_youths, -> { with_role(:youth).where({ approved: false }) }
  scope :for_social_worker, ->(user) { where(social_worker: user).with_role(:youth) }
  scope :with_status, lambda { |status|
    case status
    when 'pending'
      where(approved: false).left_joins(:survey).where(surveys: { id: nil })
    when 'denied'
      where(approved: false).left_joins(:survey).where.not(surveys: { id: nil })
    else
      # approved
      where(approved: true)
    end
  }

  scope :admin_user_filter, lambda { |keyword|
    where("users.properties->>'first_name' ILIKE ?", "%#{keyword}%")
      .or(where("users.properties->>'last_name' ILIKE ?", "%#{keyword}%"))
      .or(where('email ILIKE ?', "%#{keyword}%"))
  }

  scope :ordered, lambda { |field|
    case field
    when 'name'
      order(Arel.sql("users.properties->>'last_name' ASC, users.properties->>'first_name' ASC"))
    when 'age'
      order(
        Arel.sql(
          "DATE_PART('year', CURRENT_DATE) - DATE_PART('year', NULLIF(users.properties->>'dob', '')::DATE) ASC"
        )
      )
    when 'gender'
      order(Arel.sql("users.properties->>'gender' ASC"))
    else
      order(created_at: :desc)
    end
  }
  scope :by_keyword, lambda { |keyword|
    where("users.properties->>'username' ILIKE ?", "%#{keyword}%")
  }

  def self.humanized_profiles
    PROFILES.keys.map do |name|
      [I18n.t("model.user.role.#{name}"), name]
    end
  end

  def banned_youth?
    youth? && banned?
  end

  def name
    return unless try(:first_name) && try(:last_name)

    "#{first_name} #{last_name}"
  end

  def age
    return 0 unless try(:dob)

    Time.zone.today.year - dob.year
  end

  def transgender?
    transgender == 'yes'
  end

  def ethnicity?
    (%w[not_to_respond other] & ethnicities).empty?
  end

  def gender?
    %w[not_to_respond other].exclude?(gender)
  end

  def pronouns?
    %w[not_to_respond other].exclude?(pronouns)
  end

  def lgbt_friendly?
    lgbt_friendly == 'yes'
  end

  private

  def phone_format
    return true if phone.present? && PHONE_REGEXP =~ phone.gsub(/[\s\-()]/, '')

    errors.add(:phone, :invalid)
  end

  def correct_benefit_types
    validates_multiple_inclusion(:benefits, BENEFITS_VALUES)
  end

  def correct_ethnicity_types
    validates_multiple_inclusion(:ethnicities, ETHNICITIES_VALUES)
  end

  def social_worker_selected
    return true if social_worker.present? || social_worker_unlisted

    errors.add(:social_worker, :not_selected)
  end
end

# rubocop:enable Metrics/ClassLength
