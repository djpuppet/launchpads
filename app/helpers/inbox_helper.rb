# frozen_string_literal: true

module InboxHelper
  def messages_groups(messages)
    constructor = Inbox::Constructor.new(messages)

    constructor.call
  end
end
