# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserFilters, type: :model do
  subject(:described_obj) { described_class.new(params) }

  let(:params) { {} }

  it { is_expected.to respond_to(:sort_by, :sort_by=) }
  it { is_expected.to respond_to(:status, :status=) }
  it { is_expected.to respond_to(:keyword, :keyword=) }

  context 'with provided values' do
    let(:params) do
      {
        sort_by: described_class.sort_by.values.sample,
        status:  described_class.status.values.sample,
        keyword: Faker::Lorem.word
      }
    end

    it 'returns sort_by' do
      expect(described_obj.sort_by).to eq(params[:sort_by])
    end

    it 'returns status' do
      expect(described_obj.status).to eq(params[:status])
    end

    it 'returns keyword' do
      expect(described_obj.keyword).to eq(params[:keyword])
    end

    it 'returns filter_with_status? = true correctly' do
      described_obj.status = 'pending'
      expect(described_obj).to be_filter_with_status
    end

    it 'returns filter_with_status? = false correctly' do
      described_obj.status = 'all'
      expect(described_obj).not_to be_filter_with_status
    end
  end
end
