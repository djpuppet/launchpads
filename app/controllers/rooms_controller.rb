# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :fetch_room, only: %i[edit update show hide unhide]
  before_action :init_filters, only: %i[index]
  before_action :init_index, only: %i[index]
  skip_before_action :authenticate_user!, only: %i[index]

  include FilterableRooms

  def index; end

  def show; end

  def my
    @rooms = policy_scope(Room, policy_scope_class: RoomPolicy::OwnedRoomsScope).with_photos
    authorize @rooms
  end

  def hide
    authorize(@room)
    @room.hide!
    redirect_to :my_rooms
  end

  def unhide
    authorize(@room)
    @room.unhide!
    redirect_to :my_rooms
  end

  def new
    @room = Room.new
    authorize @room
  end

  def create
    @room = authorize current_user.rooms.build(room_params)
    if @room.save
      RoomMailer.create_room(@room).deliver_later
      flash[:notice] = notice_created_room
      redirect_to root_path
    else
      flash[:error] = 'You cannot submit this without completing all required fields'
      render :new
    end
  end

  def edit; end

  def update
    if @room.update(room_params)
      flash[:notice] = 'The listing has been successfully updated'
      redirect_to root_path
    else
      flash[:error] = 'You cannot submit this without completing all required fields'
      render :edit
    end
  end

  def validate
    init_validate_record
    if @room.valid?
      render validate_action, status: :ok
    else
      render validate_action, status: :unprocessable_entity
    end
  end

  private

  def validate_action
    params.key?(:id) ? :edit : :new
  end

  def init_validate_record
    @room = authorize Room.find_or_initialize_by(id: params[:id], user: current_user)
    @room.assign_attributes(room_validation_params)
  end

  def fetch_room
    @room = authorize Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(RoomPolicy::PERMITTED_PARAMS).reverse_merge(photos: [])
  end

  def room_validation_params
    Attachments::Base.validation_props(room_params, %i[photos])
  end

  def notice_created_room
    return I18n.t('activerecord.errors.models.room.create.user_approved') if current_user.approved?

    I18n.t('activerecord.errors.models.room.create.user_unapproved')
  end
end
