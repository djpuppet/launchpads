# frozen_string_literal: true

module AuditingObject
  class AuditingAdapter
    def initialize(controller)
      @controller = controller
      @handler = AuditingObject::AuditHandler.new
    end

    def latest(count = 100); end

    def delete_object(object, model, user)
      @handler.call('delete', model: model, object: object, user: user)
    end

    def update_object(object, model, user, changes)
      @handler.call('update', model: model, object: object, user: user, changes: changes)
    end

    def create_object(object, model, user)
      @handler.call('create', model: model, object: object, user: user)
    end

    # rubocop:disable Metrics/ParameterLists, Layout/LineLength
    def listing_for_model(model, query, sort, sort_reverse, all, page, per_page = (RailsAdmin::Config.default_items_per_page || 20))
      @handler.call('listing_model', model: model, query: query, sort: sort, sort_reverse: sort_reverse, all: all, page: page, per_page: per_page)
    end

    def listing_for_object(model, object, query, sort, sort_reverse, all, page, per_page = (RailsAdmin::Config.default_items_per_page || 20))
      @handler.call('listing_object', model: model, object: object, query: query, sort: sort, sort_reverse: sort_reverse, all: all, page: page, per_page: per_page)
    end
    # rubocop:enable Metrics/ParameterLists, Layout/LineLength
  end
end
