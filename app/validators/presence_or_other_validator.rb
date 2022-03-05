# frozen_string_literal: true

# :reek:UtilityFunction :reek:ControlParameter
class PresenceOrOtherValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return true if value != 'other'

    other_field_name = "other_#{attribute}".to_sym
    record.errors.add(other_field_name, :blank) if record.send(other_field_name).blank?
  end
end
