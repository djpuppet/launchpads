# frozen_string_literal: true

class ApplicationAdmin
  def self.attached_images_pretty_value(value, bindings)
    files = value&.map do |file|
      path = Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
      bindings[:view].tag.a(file.filename, href: path)
    end
    files.join(' ').html_safe # rubocop:disable Rails/OutputSafety
  end

  def self.related_user_pretty_value(bindings)
    user        = bindings[:object].user
    view_helper = bindings[:view]
    path        = view_helper.show_path(model_name: 'User', id: user.id)
    view_helper.link_to(user.email, path)
  end

  def self.properties_for(model_class, section)
    handler_class = "Properties::Admin::#{section.class.name.demodulize}Field".constantize
    model_class.registered_properties.each_value do |property|
      property_handler = handler_class.new(section, property)
      property_handler.call
    end
  end
end
