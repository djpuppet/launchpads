# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conversation, type: :model do
  subject(:described_obj) { described_class.new }

  let(:conversation) { create(:conversation) }
  let(:first_user) { conversation.users.first }
  let(:second_user) { conversation.users.second }

  describe 'associations' do
    it { is_expected.to have_many(:messages) }
    it { is_expected.to have_many(:conversation_users) }
    it { is_expected.to have_many(:users).through(:conversation_users) }
  end

  describe 'validations' do
    let(:youth) { create(:user, :youth, :with_valid_parameters) }
    let(:host) { create(:user, :host, :with_valid_parameters) }
    let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }

    it 'validates conversation users min number' do
      conversation = build(:conversation, users: [youth])
      expect(conversation).not_to be_valid
      expect(conversation.errors).to be_key(:users)
    end

    it 'validates conversation users max number' do
      conversation = build(:conversation, users: [youth, host, social_worker, create(:user, :host)])
      expect(conversation).not_to be_valid
      expect(conversation.errors).to be_key(:users)
    end

    it 'validates conversation users include host' do
      conversation = build(:conversation, users: [youth, social_worker])
      expect(conversation).not_to be_valid
      expect(conversation.errors).to be_key(:conversation_users)
    end

    it 'validates conversation users include youth' do
      conversation = build(:conversation, users: [host, social_worker])
      expect(conversation).not_to be_valid
      expect(conversation.errors).to be_key(:conversation_users)
    end

    it 'validates conversation users include only single youth' do
      conversation = build(:conversation, users: [youth, host, create(:user, :youth)])
      expect(conversation).not_to be_valid
      expect(conversation.errors).to be_key(:conversation_users)
    end

    it 'validates conversation users include only single host' do
      conversation = build(:conversation, users: [youth, host, create(:user, :host)])
      expect(conversation).not_to be_valid
      expect(conversation.errors).to be_key(:conversation_users)
    end

    it 'allows social_worker as a third user' do
      conversation = build(:conversation, users: [youth, host, social_worker])
      expect(conversation).to be_valid
    end
  end

  # rubocop:disable RSpec/PredicateMatcher
  describe 'read_by?' do
    context 'when both users have read all messages' do
      it 'confirms that every users have read messages' do
        expect(conversation.read_by?(first_user)).to be_truthy
        expect(conversation.read_by?(second_user)).to be_truthy
      end
    end

    context "when one of users hasn't read a message" do
      let(:conversation_first_user) { conversation.conversation_users.find_by(user: first_user) }

      before do
        conversation_first_user.update(read: false)
      end

      it 'confirms that the first user has an unread message' do
        expect(conversation.read_by?(first_user)).to be_falsey
        expect(conversation.read_by?(second_user)).to be_truthy
      end
    end
  end

  describe 'read!' do
    let(:conversation_first_user) { conversation.conversation_users.find_by(user: first_user) }

    before do
      conversation_first_user.update(read: false)
    end

    it 'changes an attribute value on true' do
      expect(conversation.read_by?(first_user)).to be_falsey
      expect(conversation.read!(first_user)).to be_truthy
      expect(conversation.read_by?(first_user)).to be_truthy
    end
  end

  describe 'ignored_by?' do
    context "when users didn't request to ignore the conversation" do
      it "confirms that any user doesn't ignore conversation" do
        expect(conversation.ignored_by?(first_user)).to be_falsey
        expect(conversation.ignored_by?(second_user)).to be_falsey
      end
    end

    context 'when one of user requests to ignore conversation' do
      before do
        conversation.ignore!(first_user)
      end

      it 'confirms that one of members ignore the conversation' do
        expect(conversation.ignored_by?(first_user)).to be_truthy
        expect(conversation.ignored_by?(second_user)).to be_falsey
      end
    end
  end

  describe 'ignore!' do
    it 'changes the ignore flag on true' do
      conversation.ignore!(second_user)
      expect(conversation.ignored_by?(first_user)).to be_falsey
      expect(conversation.ignored_by?(second_user)).to be_truthy
    end
  end

  describe 'unignore!' do
    before do
      conversation.ignore!(first_user)
      conversation.ignore!(second_user)
    end

    it 'changes the ignore flag on true' do
      conversation.unignore!(first_user)
      expect(conversation.ignored_by?(first_user)).to be_falsey
      expect(conversation.ignored_by?(second_user)).to be_truthy
    end
  end

  describe 'includes_youth?' do
    let(:youth) { create(:user, :youth, :with_valid_parameters) }
    let(:host) { create(:user, :host, :with_valid_parameters) }
    let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }

    context 'when one of participants of conversation is a youth' do
      let(:conversation) { create(:conversation, users: [youth, host]) }

      it 'finds youth in the conversation' do
        expect(conversation.includes_youth?).to be_truthy
      end
    end
  end

  describe 'includes_social_worker?' do
    let(:youth) { create(:user, :youth, :with_valid_parameters) }
    let(:host) { create(:user, :host, :with_valid_parameters) }
    let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }

    context 'when one of participants of conversation is a social worker' do
      let(:conversation) { create(:conversation, users: [youth, host, social_worker]) }

      it 'finds youth in the conversation' do
        expect(conversation.includes_social_worker?).to be_truthy
      end
    end

    context "when the conversation doesn't include social worker" do
      let(:conversation) { create(:conversation, users: [host, youth]) }

      it "doesn't find youth in the conversation" do
        expect(conversation.includes_social_worker?).to be_falsey
      end
    end
  end
  # rubocop:enable RSpec/PredicateMatcher

  describe 'with_participants' do
    let(:youth) { create(:user, :youth, :with_valid_parameters) }
    let(:host) { create(:user, :host, :with_valid_parameters) }
    let(:users) { [youth, host] }

    before do
      create_list(:conversation, 3)
    end

    # the conversation is created on the top when we execute first_user or second_user
    context "when conversation between users doesn't exist" do
      it 'returns empty array' do
        expect(described_class.with_participants(users)).to be_empty
      end
    end

    context 'when there is the one conversation between users' do
      before { create(:conversation, users: users) }

      it 'finds that conversation' do
        expect(described_class.with_participants(users).count).to eq(1)
      end
    end

    context 'when there are more conversations between users' do
      let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }

      before do
        create(:conversation, users: users)
        users << social_worker
        create(:conversation, users: users)
      end

      it 'finds that conversation between youth and host' do
        expect(described_class.with_participants([youth, host]).count).to eq(1)
      end

      it 'finds that conversation between youth and host and social worker' do
        expect(described_class.with_participants([youth, host, social_worker]).count).to eq(1)
      end
    end
  end

  describe 'with_participants_no' do
    let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }
    let(:youth) { create(:user, :youth, :with_valid_parameters) }
    let(:other_youth) { create(:user, :youth, :with_valid_parameters) }
    let(:host) { create(:user, :host, :with_valid_parameters) }
    let(:other_host) { create(:user, :host, :with_valid_parameters) }

    before do
      create(:conversation, users: [youth, host])
      create(:conversation, users: [other_youth, other_host])
      create(:conversation, users: [youth, host, social_worker])
      create(:conversation, users: [other_youth, other_host, social_worker])
    end

    context 'when size = 1' do
      it 'finds two conversation' do
        expect(described_class.with_participants_no(1).length).to eq 0
      end
    end

    context 'when size = 2' do
      it 'finds two conversation' do
        expect(described_class.with_participants_no(2).length).to eq 2
      end
    end

    context 'when size = 3' do
      it 'finds one conversation' do
        expect(described_class.with_participants_no(3).length).to eq 2
      end
    end

    context 'when the argument is 4' do
      it "doesn't find any conversations" do
        expect(described_class.with_participants_no(4).length).to eq 0
      end
    end
  end

  describe 'with_exact_participants' do
    let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }
    let(:youth) { create(:user, :youth, :with_valid_parameters) }
    let(:other_youth) { create(:user, :youth, :with_valid_parameters) }
    let(:host) { create(:user, :host, :with_valid_parameters) }
    let(:other_host) { create(:user, :host, :with_valid_parameters) }

    before do
      create(:conversation, users: [youth, host])
      create(:conversation, users: [youth, host, social_worker])
      create(:conversation, users: [youth, other_host, social_worker])
      create(:conversation, users: [other_youth, other_host, social_worker])
    end

    context 'when there are conversations between users' do
      it 'finds exact one conversation' do
        expect(described_class.with_exact_participants([youth, host]).length).to eq 1
        expect(described_class.with_exact_participants([youth, host, social_worker]).length).to eq 1
        expect(described_class.with_exact_participants([youth, other_host, social_worker]).length).to eq 1
      end
    end

    context 'when there are no conversations between users' do
      it "doesn't find any conversations" do
        expect(described_class.with_exact_participants([other_youth, other_host]).length).to eq 0
        expect(described_class.with_exact_participants([other_youth, host]).length).to eq 0
        expect(described_class.with_exact_participants([other_youth, host, social_worker]).length).to eq 0
      end
    end
  end

  describe 'find_social_worker' do
    let(:social_worker) { create(:user, :social_worker, :with_valid_parameters) }
    let(:youth) { create(:user, :youth, :with_valid_parameters, social_worker: social_worker) }
    let(:host) { create(:user, :host, :with_valid_parameters) }
    let(:conversation) { create(:conversation, users: [youth, host]) }

    context 'when youth has social worker assigned' do
      it 'finds the social worker' do
        expect(conversation.find_social_worker).to eq(social_worker)
      end
    end

    context 'when youth doesn\'t have social worker assigned' do
      before do
        youth.update(social_worker: nil, social_worker_unlisted: true)
      end

      it 'returns nil' do
        expect(conversation.find_social_worker).to be_nil
      end
    end
  end
end
