# frozen_string_literal: true

module Inbox
  class MessagesGroup
    attr_reader :messages, :date_changed

    def initialize(is_odd, date_changed)
      @odd          = is_odd
      @date_changed = date_changed
      @messages     = []
    end

    def add_message(message)
      @messages << message
    end

    def odd?
      @odd
    end
  end
end
