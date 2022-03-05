# frozen_string_literal: true

module WithProperties
  def self.extended(base)
    base.send :include, WithProperties::Base
  end

  # Method can be used to register new custom property.
  # A type should be specified for the property. If the type is not supported, a `generic` type will be used.
  def property(name, type, options = {})
    property                    = options.merge({ field_name: name, field_type: type })
    registered_properties[name] = property
    ::Properties::Attribute.new(property, self).call
  end

  # Wrapper for #validates method.
  # Ensures that validations are fired ONLY for properties that require them.
  # Property requires validation if property_options[:roles] includes the current record's role
  #
  # Initial arguments are property_names to be passed to the method that checks if validation should be applied.
  # args.last is an options hash (if available)
  def property_validates(*attributes)
    options = attributes.extract_options!
    merge_validation_if(attributes, options)

    validates(*attributes, options)
  end

  # Wrapper for #validate method.
  # Ensures that validations are fired ONLY for properties that require them.
  # Property requires validation if property_options[:roles] includes the current record's role
  #
  # Original ActiveModel::Validations::ClassMethods#validate accepts a list of methods to call during validation.
  # This wrapper accepts a list of conditional properties, a single validation method and options hash instead.
  #
  # Initial arguments are property_names to be passed to the method that checks if validation should be applied.
  # args[-1] is a validation method name to be applied
  # args.last is an options hash (if available)
  # :reek:FeatureEnvy
  def property_validate(*args, &block)
    options = args.extract_options!
    # Take all conditional properties names and options hash (skip validation method name which is args.last)
    merge_validation_if(args[0...-1], options)

    # Call validate with a method passed as a last element of args array.
    # All items from the beginning are properties names.
    validate(args.last, options, &block)
  end

  # Contains a hash of defined custom properties. Uses field_name as indexes and property options as values.
  # Usage of Hash helps in retrieving a specific field's options.
  def registered_properties
    @registered_properties ||= {}
  end

  # Method attached conditional to validation options.
  # It preserves all previous conditionals passed in :if option and adds another one.
  # The new validation iterates over ALL conditional properties passed and if for ALL of the properties roles are
  #   matching validated record role, the validation rule will be applied
  # :reek:DuplicateMethodCall
  def merge_validation_if(properties_to_apply, options)
    properties   = registered_properties.values_at(*properties_to_apply)
    # make sure options[:if] is always an array and push lambda that verifies if validation should be applied
    options[:if] = Array(options[:if]).push(
      -> { properties.all? { |property| !property.key?(:roles) || property[:roles].include?(role&.to_sym) } }
    )

    options
  end

  # Module that groups all _instance_ methods that should be applied to model.
  module Base
    extend ActiveSupport::Concern

    included do
      after_validation -> { parse_to_properties if errors.empty? }
    end

    # :reek:DuplicateMethodCall
    def parse_to_properties
      self.class.registered_properties.each_value do |property|
        # do not parse property that does not belong to this record
        next if property.key?(:roles) && property[:roles].exclude?(role&.to_sym)

        field_name             = property[:field_name].to_s
        properties[field_name] = send(field_name)
      end
    end

    # Provides missing validation method that checks if all provided items in an array are included in allowed values.
    def validates_multiple_inclusion(property_name, values)
      items = send(property_name)
      return true if items.blank?

      errors.add(property_name, :invalid) if items.detect { |item| values.exclude?(item) }
    end
  end
end
