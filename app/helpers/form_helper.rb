# frozen_string_literal: true

module FormHelper
  def add_error_class(form_builder, property)
    'has-errors' if form_builder.object.errors.key?(property)
  end
end
