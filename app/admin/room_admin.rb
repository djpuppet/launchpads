# :nocov:
# frozen_string_literal: true

module RoomAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        field :id
        field :title do
          searchable ["properties->>'title'"]
          queryable true
        end
        field :user do
          pretty_value do
            ApplicationAdmin.related_user_pretty_value(bindings)
          end
          searchable [:email]
          queryable true
        end
      end

      edit do
        field :user_id, :enum do
          enum do
            User.with_role(:host).map { |user| [user.email, user.id] }
          end
        end
        field :hidden
        field :photos, :multiple_active_storage do
          attachment_class(UploadedAttachment)
        end
        ApplicationAdmin.properties_for(Room, self)
        fields do
          help false
        end
      end

      show do
        field :user do
          pretty_value do
            ApplicationAdmin.related_user_pretty_value(bindings)
          end
        end
        field :photos, :multiple_active_storage do
          pretty_value do
            ApplicationAdmin.attached_images_pretty_value(value, bindings)
          end
        end
        ApplicationAdmin.properties_for(Room, self)
      end

      export do
        exclude_fields :photos
      end
    end
  end
end
