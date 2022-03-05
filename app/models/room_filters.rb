# frozen_string_literal: true

class RoomFilters
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :defaults_used

  def initialize(params)
    @defaults_used = params.empty?

    super(params)
  end

  attribute :max_price, :integer, default: 1500
  attribute :duration_of_stay, :integer, default: 0
  attribute :child_friendly, :boolean, default: false
  attribute :pet_friendly, :boolean, default: false
  attribute :no_smoking, :boolean, default: false
  attribute :cities, default: []

  def self.attribute_names
    attributes = super - ['cities']

    attributes + [cities: []]
  end

  def cities=(value)
    super(value.reject(&:empty?))
  end
end
