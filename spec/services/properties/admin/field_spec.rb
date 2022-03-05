# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Properties::Admin::Field do
  let(:section) { double }
  let(:property) do
    {
      field_type: :generic
    }
  end
  let(:described_obj) { described_class.new(section, property) }

  describe '#call' do
    it 'raises not implemented error' do
      expect { described_obj.call }.to raise_error(NotImplementedError)
    end
  end
end
