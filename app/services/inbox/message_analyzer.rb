# frozen_string_literal: true

module Inbox
  class MessageAnalyzer
    attr_reader :analysis

    def initialize(message, previous_props)
      @message  = message
      @analysis = Result.new(
        date_changed: previous_props[:date] != message.created_at.to_date,
        **previous_props
      )
    end

    def analyze
      @analysis.increment_index if should_increment_index?
      update_alignment
      update_author
      update_date
    end

    private

    def should_increment_index?
      @analysis.author_id != @message.user.id || @analysis.date != @message.created_at.to_date
    end

    def update_author
      @analysis.update_author_id(@message.user.id)
    end

    def update_alignment
      @analysis.switch_alignment if @analysis.author_id != @message.user.id
    end

    def update_date
      @analysis.update_date(@message.created_at.to_date) if @analysis.date_changed
    end

    # :reek:TooManyInstanceVariables { max_instance_variables: 5 }
    class Result
      attr_reader :index, :author_id, :date, :date_changed

      def initialize(author_id:, date:, odd:, date_changed:)
        @index        = 0
        @author_id    = author_id
        @date         = date
        @odd          = odd
        @date_changed = date_changed
      end

      def odd?
        @odd
      end

      def switch_alignment
        @odd = !odd?
      end

      def update_author_id(new_id)
        @author_id = new_id
      end

      def update_date(new_date)
        @date = new_date
      end

      def increment_index
        @index += 1
      end
    end
  end
end
