# frozen_string_literal: true

class UploadedAttachment < RailsAdmin::Config::Fields::Types::MultipleActiveStorage::ActiveStorageAttachment
  register_instance_option :pretty_value do
    return if value.blank?

    locals = {
      url:    resource_url,
      value:  value,
      form:   bindings[:form],
      object: bindings[:object]
    }

    if image
      locals[:image]     = true
      locals[:thumb_url] = resource_url(thumb_method)
    end

    bindings[:view].render(
      partial: 'uploaded-attachment',
      locals:  locals
    )
  end

  register_instance_option :thumb_method do
    nil
  end
end
