# frozen_string_literal: true

module Attachments
  class Base
    def self.validation_props(parameters, properties)
      parameters.tap do |params|
        properties.each do |prop|
          # Replace all photos with empty blobs to perform validation of photos count and not throw errors
          # This is due to the fact that photos are uploaded only on form submit, not on validation action
          replace_empty_with_blobs(params[prop])
        end
      end
    end

    private_class_method def self.replace_empty_with_blobs(param)
      param.map! { |attachment| attachment.presence || ActiveStorage::Blob.new(filename: '', byte_size: 0) }
    end
  end
end
