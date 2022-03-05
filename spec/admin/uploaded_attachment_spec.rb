# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadedAttachment do
  let(:value) { double }
  let(:blob) { double }
  let(:view) { double }
  let(:url) { Faker::Internet.url }
  let(:described_obj) { described_class.new(value) }

  before do
    allow(value).to receive(:blob).and_return(blob)
    allow(value).to receive(:present?).and_return(true)
    allow(value).to receive(:filename).and_return(Faker::Lorem.word)
    allow(blob).to receive(:byte_size).and_return(0)
    allow(view).to receive(:render)
    allow(described_obj).to receive(:resource_url).and_return(url)
    allow(described_obj).to receive(:bindings).and_return({ view: view, form: nil, object: nil })
  end

  it 'returns link in to photo as a pretty_value' do
    described_obj.pretty_value
    expect(view).to(
      have_received(:render)
        .with({ partial: 'uploaded-attachment', locals: { form: nil, object: nil, url: url, value: value } })
    )
  end
end
