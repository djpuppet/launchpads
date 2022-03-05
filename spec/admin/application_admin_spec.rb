# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationAdmin do
  let(:view) { double }
  let(:object) { double }
  let(:bindings) do
    {
      view:   view,
      object: object
    }
  end
  let(:value) { [] }
  let(:section) { double }
  let(:model_class) { double }

  describe '#attached_images_pretty_value' do
    before do
      allow(value).to receive(:map).and_call_original
      allow(view).to receive(:content_tag).and_return('')
    end

    it 'returns html_safe string' do
      expect(
        described_class.attached_images_pretty_value(value, bindings)
      ).to be_html_safe
    end
  end

  describe '#related_user_pretty_value' do
    before do
      allow(object).to receive(:user).and_return(build(:user, :host))
      allow(view).to receive(:show_path).and_return('#')
      allow(view).to receive(:link_to).and_return('<a>Link</a>')
    end

    it 'returns link to User resource' do
      described_class.related_user_pretty_value(bindings)
      expect(object).to have_received(:user)
      expect(view).to have_received(:show_path)
      expect(view).to have_received(:link_to)
    end
  end

  describe '#properties_for' do
    let(:handler) { double }
    let(:properties) do
      {
        property1: double,
        property2: double
      }
    end

    before do
      stub_const('Properties::Admin::ShowField', handler)
      allow(handler).to receive(:new).and_return(handler)
      allow(handler).to receive(:call)
      allow(section).to receive(:class).and_return(RailsAdmin::Config::Sections::Show)
      allow(model_class).to receive(:registered_properties).and_return(properties)
      described_class.properties_for(model_class, section)
    end

    it 'iterates over all properties of a model' do
      expect(model_class).to have_received(:registered_properties)
      expect(handler).to have_received(:new).with(section, properties.values[0])
      expect(handler).to have_received(:new).with(section, properties.values[1])
      expect(handler).to have_received(:call).twice
    end
  end
end
