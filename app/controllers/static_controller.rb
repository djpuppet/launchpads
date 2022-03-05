# frozen_string_literal: true

class StaticController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :skip_authorization, only: %i[index styleguide]

  include FilterableRooms

  def index
    if current_user.present?
      signed_in_index
    else
      anonymous_index
    end
  end

  def styleguide; end

  private

  def signed_in_index
    @recently_added = Room.visible.with_photos.limit(3).order(created_at: :desc)
    init_filters
    init_index
    render 'index-signed-in'
  end

  def anonymous_index
    render :index
  end
end
