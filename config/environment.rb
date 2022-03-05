# frozen_string_literal: true

require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Remove unnecessary .field_wih_errors wrapper
ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  # rubocop:disable Rails/OutputSafety
  html_tag.html_safe
  # rubocop:enable Rails/OutputSafety
end
