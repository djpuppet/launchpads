# :nocov:
# frozen_string_literal: true

module UserAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        field :id
        field :email
        field :first_name do
          searchable ["properties->>'first_name'"]
          queryable true
        end
        field :last_name do
          searchable ["properties->>'last_name'"]
          queryable true
        end
        field :approved do
          searchable ["properties->>'approved'"]
          queryable true
        end
        field :role
        field :created_at
        field :updated_at
        exclude_fields :password, :password_confirmation, :reset_password_sent_at, :remember_created_at,
                       :confirmation_token, :confirmation_sent_at, :unconfirmed_email, :properties, :photos
        search_by :admin_user_filter
      end

      edit do
        field :email
        field :role, :enum do
          read_only do
            user = bindings[:object]
            user.role.present?
          end
          enum do
            User.role.values.map { |role| [role.humanize, role] }
          end
          formatted_value do
            bindings[:object].role
          end
        end
        field :social_worker_id, :enum do
          enum do
            User.with_role(:social_worker).map { |user| [user.name, user.id] }
          end
          visible do
            bindings[:object].role == :youth
          end
        end
        field :approved
        field :banned do
          visible do
            bindings[:object].role == :youth
          end
        end
        field :photos, :multiple_active_storage do
          attachment_class(UploadedAttachment)
        end
        ApplicationAdmin.properties_for(User, self)

        exclude_fields :password, :password_confirmation, :reset_password_sent_at, :remember_created_at,
                       :confirmation_token, :confirmation_sent_at, :unconfirmed_email, :confirmed_at
        fields do
          help false
        end
      end

      show do
        field :email
        field :role
        field :approved
        field :banned do
          visible do
            bindings[:object].role == :youth
          end
        end
        field :photos, :multiple_active_storage do
          pretty_value do
            ApplicationAdmin.attached_images_pretty_value(value, bindings)
          end
        end
        ApplicationAdmin.properties_for(User, self)
        field :created_at
        field :updated_at
      end

      export do
        exclude_fields :photos
      end
    end
  end
end
# :nocov:
