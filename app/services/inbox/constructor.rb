# frozen_string_literal: true

module Inbox
  class Constructor
    def initialize(messages)
      @messages = messages
      @groups   = []
      @index    = 0
    end

    def call
      analyze_messages

      @groups
    end

    private

    def analyze_messages
      @messages.each do |message|
        init_analyzer(message)
        update_index
        add_message(message)
      end
    end

    def init_analyzer(message)
      analyzer = MessageAnalyzer.new(
        message,
        {
          author_id: @analysis&.author_id || message.user.id,
          date:      @analysis&.date || message.created_at.to_date,
          odd:       @analysis&.odd?
        }
      )
      analyzer.analyze
      @analysis = analyzer.analysis
    end

    def update_index
      @index += @analysis.index
    end

    def add_message(message)
      group.add_message(message)
    end

    def group
      @groups[@index] ||= MessagesGroup.new(@analysis.odd?, @analysis.date_changed)
    end
  end
end
