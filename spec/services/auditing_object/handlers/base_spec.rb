# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditingObject::Handlers::Base, type: :service do
  let(:described_obj) { described_class.new(args) }
  let(:args) { double }

  describe '#index' do
    it 'returns nil' do
      expect(described_obj.index).to be_nil
    end
  end

  describe '#new' do
    it 'returns nil' do
      expect(described_obj.new).to be_nil
    end
  end

  describe '#create' do
    it 'returns nil' do
      expect(described_obj.create).to be_nil
    end
  end

  describe '#edit' do
    it 'returns nil' do
      expect(described_obj.edit).to be_nil
    end
  end

  describe '#update' do
    it 'returns nil' do
      expect(described_obj.update).to be_nil
    end
  end

  describe '#delete' do
    it 'returns nil' do
      expect(described_obj.delete).to be_nil
    end
  end
end
