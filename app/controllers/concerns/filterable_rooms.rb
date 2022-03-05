# frozen_string_literal: true

module FilterableRooms
  extend ActiveSupport::Concern

  private

  def init_index
    @rooms = paginate(filtered_rooms_list, 9)
    authorize(@rooms)
  end

  def init_filters
    @filters = RoomFilters.new(filter_params)
  end

  def filter_params
    params
      .fetch(:room_filters, {})
      .permit(RoomFilters.attribute_names)
  end

  def filtered_rooms_list
    ScopeFilter.new(policy_scope(Room).with_photos, @filters)
               .apply_price_filters
               .apply_duration_of_stay_filters
               .apply_children_friendly_filters
               .apply_pet_friendly_filters
               .apply_cities_filters
               .fetch
  end

  # :reek:DuplicateMethodCall { max_calls: 2 }
  class ScopeFilter
    def initialize(scope, filters)
      @scope   = scope
      @filters = filters
    end

    def fetch
      @scope
    end

    def apply_price_filters
      @scope = @scope.max_price(@filters.max_price)
      self
    end

    def apply_duration_of_stay_filters
      @scope = @scope.duration_of_stay(@filters.duration_of_stay) if @filters.duration_of_stay
      self
    end

    def apply_children_friendly_filters
      @scope = @scope.children_friendly if @filters.child_friendly

      self
    end

    def apply_pet_friendly_filters
      @scope = @scope.pet_friendly if @filters.pet_friendly

      self
    end

    def apply_cities_filters
      @scope = @scope.from_cities(@filters.cities) if @filters.cities.any?

      self
    end
  end
end
