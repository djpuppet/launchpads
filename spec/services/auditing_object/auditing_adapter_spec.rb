# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditingObject::AuditingAdapter, type: :service do
  let(:controller) { double }
  let(:described_obj) { described_class.new(controller) }
  let(:handler) { described_obj.instance_variable_get(:@handler) }
  let(:object) { double }
  let(:model) { Faker::Lorem.word }
  let(:user) { Faker::Internet.username }
  let(:changes) { Faker::Lorem.word }
  let(:query) { Faker::Lorem.word }
  let(:sort) { Faker::Boolean.boolean }
  let(:sort_reverse) { Faker::Boolean.boolean }
  let(:all) { Faker::Lorem.word }
  let(:page) { Faker::Number.digit }
  let(:per_page) { Faker::Number.digit }

  before do
    allow(handler).to receive(:call)
  end

  describe '#delete_object' do
    before { described_obj.delete_object(object, model, user) }

    it 'has the appropriate arguments' do
      expect(handler).to have_received(:call).with('delete',
                                                   model:  model,
                                                   object: object,
                                                   user:   user)
    end
  end

  describe '#update_object' do
    before { described_obj.update_object(object, model, user, changes) }

    it 'has the appropriate arguments' do
      expect(handler).to have_received(:call).with('update',
                                                   model:   model,
                                                   object:  object,
                                                   user:    user,
                                                   changes: changes)
    end
  end

  describe '#create_object' do
    it 'has the appropriate arguments' do
      described_obj.create_object(object, model, user)
      expect(handler).to have_received(:call).with('create',
                                                   model:  model,
                                                   object: object,
                                                   user:   user)
    end
  end

  describe '#listing_for_model' do
    let(:arguments) do
      { model: model, query: query, sort: sort, sort_reverse: sort_reverse, all: all, page: page, per_page: per_page }
    end

    before { described_obj.listing_for_model(model, query, sort, sort_reverse, all, page, per_page) }

    it 'has the appropriate arguments' do
      expect(handler).to have_received(:call).with('listing_model', arguments)
    end
  end

  describe '#listing_for_object' do
    let(:arguments) do
      { model:        model,
        object:       object,
        query:        query,
        sort:         sort,
        sort_reverse: sort_reverse,
        all:          all,
        page:         page,
        per_page:     per_page }
    end

    before { described_obj.listing_for_object(model, object, query, sort, sort_reverse, all, page, per_page) }

    it 'has the appropriate arguments' do
      expect(handler).to have_received(:call).with('listing_object', arguments)
    end
  end
end
