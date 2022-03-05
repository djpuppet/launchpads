# frozen_string_literal: true

class UserFilters
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend Enumerize

  attribute :sort_by, :string
  attribute :status, :string
  enumerize :sort_by, in: %w[name gender age], default: 'name'
  enumerize :status, in: %w[all pending denied approved], default: 'pending'
  attribute :keyword, :string

  def filter_with_status?
    status.present? && status != 'all'
  end
end
