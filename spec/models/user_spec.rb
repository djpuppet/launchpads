# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:role) { User::ROLES }

  it 'removes empty values from benefits' do
    described_obj          = build(:user, :youth)
    described_obj.benefits = [''] + User::BENEFITS_VALUES.sample(2)
    described_obj.valid?
    expect(described_obj.benefits.size).to eq(2)
  end

  it 'removes empty values from ethnicities' do
    described_obj = build(:user, :youth)
    described_obj.ethnicities = [''] + User::ETHNICITIES_VALUES.sample(2)
    described_obj.valid?
    expect(described_obj.ethnicities.size).to eq(2)
  end

  describe '#validation' do
    let(:phone_numbers) { ['123 456 7890', '(123) 456 7890', '123-456-7890'] }
    let(:invalid_phone_numbers) { ['0123 4562 7890', '+(123) 456 7890', '124567890'] }

    it { is_expected.to enumerize(:role).in(role).with_scope(true) }

    context 'when :youth' do
      subject(:described_obj) { create(:user, :youth, :with_valid_parameters) }

      it 'allows valid benefits values' do
        described_obj.benefits = User::BENEFITS_VALUES.sample(2)
        described_obj.valid?
        expect(described_obj.errors).not_to be_of_kind(:benefits)
      end

      it 'disallows invalid benefits values' do
        described_obj.benefits = Faker::Lorem.words(number: 2)
        described_obj.valid?
        expect(described_obj.errors).to be_of_kind(:benefits)
      end

      it 'allows valid ethnicities values' do
        described_obj.ethnicities = User::ETHNICITIES_VALUES.sample(2)
        described_obj.valid?
        expect(described_obj.errors).not_to be_of_kind(:ethnicities)
      end

      it 'disallows invalid ethnicities values' do
        described_obj.ethnicities = Faker::Lorem.words(number: 2)
        described_obj.valid?
        expect(described_obj.errors).to be_of_kind(:ethnicities)
      end

      it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
      it { is_expected.not_to allow_value('invalid_email').for(:email) }
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_presence_of(:first_name).on(:update) }
      it { is_expected.to validate_presence_of(:last_name).on(:update) }
      it { is_expected.to validate_presence_of(:username).on(:update) }
      it { is_expected.to validate_presence_of(:phone).on(:update) }
      it { is_expected.to validate_presence_of(:about).on(:update) }
      it { is_expected.to validate_numericality_of(:children).on(:update) }
      it { is_expected.to validate_inclusion_of(:gender).in_array(User::GENDER_VALUES).on(:update) }

      it { is_expected.to validate_inclusion_of(:pronouns).in_array(User::PRONOUNS_VALUES).on(:update) }
      it { is_expected.to validate_inclusion_of(:transgender).in_array(User::TRANSGENDER_VALUES).on(:update) }
      it { is_expected.to validate_inclusion_of(:show_gender).in_array([true, false]).on(:update) }
      it { is_expected.to validate_inclusion_of(:show_ethnicity).in_array([true, false]).on(:update) }
      it { is_expected.to validate_inclusion_of(:show_pronouns).in_array([true, false]).on(:update) }
      it { is_expected.to validate_inclusion_of(:show_transgender).in_array([true, false]).on(:update) }
      it { is_expected.to validate_acceptance_of(:visible_messages_agreement).on(:update) }

      describe 'phone validation' do
        context 'when got valid phone number format' do
          it 'is valid' do
            described_obj.phone = phone_numbers.sample
            described_obj.valid?
            expect(described_obj.errors).not_to be_of_kind(:phone)
          end
        end

        context 'when got invalid phone number format' do
          it 'is invalid' do
            described_obj.phone = invalid_phone_numbers.sample
            described_obj.valid?
            expect(described_obj.errors).to be_of_kind(:phone)
          end
        end
      end
    end

    context 'when :host' do
      subject(:described_obj) { create(:user, :host) }

      it 'ignores invalid benefits values' do
        described_obj.benefits = Faker::Lorem.words(number: 2)
        described_obj.valid?
        expect(described_obj.errors).not_to be_of_kind(:benefits)
      end

      it { is_expected.to validate_presence_of(:first_name).on(:update) }
      it { is_expected.to validate_presence_of(:last_name).on(:update) }
      it { is_expected.to validate_presence_of(:username).on(:update) }
      it { is_expected.to validate_presence_of(:about).on(:update) }
      it { is_expected.to validate_inclusion_of(:gender).in_array(User::GENDER_VALUES).on(:update) }
      it { is_expected.not_to validate_presence_of(:gender).on(:update) }
      it { is_expected.not_to validate_numericality_of(:children).on(:update) }

      it {
        expect(described_obj).to validate_inclusion_of(:pronouns)
          .in_array(User::PRONOUNS_VALUES).on(:update)
      }

      it { is_expected.to validate_inclusion_of(:show_gender).in_array([true, false]).on(:update) }
      it { is_expected.to validate_inclusion_of(:show_pronouns).in_array([true, false]).on(:update) }
      it { is_expected.to validate_inclusion_of(:show_transgender).in_array([true, false]).on(:update) }
      it { is_expected.to validate_acceptance_of(:visible_messages_agreement).on(:update) }
      it { is_expected.not_to validate_inclusion_of(:show_ethnicity).in_array([true, false]).on(:update) }

      it {
        expect(described_obj).to validate_inclusion_of(:transgender)
          .in_array(User::TRANSGENDER_VALUES).on(:update)
      }

      describe 'phone validation' do
        context 'when got valid phone number format' do
          it 'is valid' do
            described_obj.phone = phone_numbers.sample
            described_obj.valid?
            expect(described_obj.errors).not_to be_of_kind(:phone)
          end
        end

        context 'when got invalid phone number format' do
          it 'is invalid' do
            described_obj.phone = invalid_phone_numbers.sample
            described_obj.valid?
            expect(described_obj.errors).to be_of_kind(:phone)
          end
        end
      end
    end

    context 'when :social_worker' do
      subject(:described_obj) { create(:user, :social_worker) }

      it 'ignores invalid benefits values' do
        described_obj.benefits = Faker::Lorem.words(number: 2)
        described_obj.valid?
        expect(described_obj.errors).not_to be_of_kind(:benefits)
      end

      it { is_expected.to validate_presence_of(:first_name).on(:update) }
      it { is_expected.to validate_presence_of(:last_name).on(:update) }
      it { is_expected.not_to validate_presence_of(:phone).on(:update) }
      it { is_expected.not_to validate_numericality_of(:children).on(:update) }

      it { is_expected.not_to validate_inclusion_of(:gender).in_array(User::GENDER_VALUES).on(:update) }

      it {
        expect(described_obj).not_to validate_inclusion_of(:pronouns)
          .in_array(User::PRONOUNS_VALUES).on(:update)
      }

      it { is_expected.not_to validate_inclusion_of(:show_gender).in_array([true, false]).on(:update) }
      it { is_expected.not_to validate_inclusion_of(:show_ethnicity).in_array([true, false]).on(:update) }
      it { is_expected.not_to validate_inclusion_of(:show_pronouns).in_array([true, false]).on(:update) }
      it { is_expected.not_to validate_inclusion_of(:show_transgender).in_array([true, false]).on(:update) }
      it { is_expected.not_to validate_acceptance_of(:visible_messages_agreement).on(:update) }

      it {
        expect(described_obj).not_to validate_inclusion_of(:transgender)
          .in_array([true, false]).on(:update)
      }

      describe 'phone validation' do
        context 'when got valid phone number format' do
          it 'is valid' do
            described_obj.phone = phone_numbers.sample
            described_obj.valid?
            expect(described_obj.errors).not_to be_of_kind(:phone)
          end
        end

        context 'when got invalid phone number format' do
          it 'is valid' do
            described_obj.phone = invalid_phone_numbers.sample
            described_obj.valid?
            expect(described_obj.errors).not_to be_of_kind(:phone)
          end
        end
      end
    end
  end

  describe 'self#humanized_profiles' do
    it 'returns an array' do
      expect(described_class.humanized_profiles).to eq([
                                                         ['I am a social worker', :social_worker],
                                                         ['I want to list a room', :host],
                                                         ['I want to rent a room', :youth]
                                                       ])
    end
  end

  describe 'banned_youth?' do
    let(:roles_without_youth) { described_class.role.values - ['youth'] }
    let(:youth) { create(:user, :youth, :with_valid_parameters) }
    let(:user) { create(:user, roles_without_youth.sample, :with_valid_parameters) }

    # rubocop:disable RSpec/PredicateMatcher
    context 'when user is an youth' do
      context 'when user is not banned' do
        it 'returns false' do
          expect(youth.banned_youth?).to be_falsey
        end
      end

      context 'when youth is banned' do
        before { youth.update(banned: true) }

        it 'returns true' do
          expect(youth.banned_youth?).to be_truthy
        end
      end
    end

    context 'when the user has a different role' do
      context 'when user is not banned' do
        it 'returns false' do
          expect(user.banned_youth?).to be_falsey
        end
      end

      context 'when user is banned' do
        before { user.update(banned: true) }

        it 'returns false' do
          expect(youth.banned_youth?).to be_falsey
        end
      end
    end
    # rubocop:enable RSpec/PredicateMatcher
  end

  describe 'after_validation' do
    let(:first_name) { Faker::Name.first_name }
    let(:described_obj) do
      create(:user, :host, properties: { 'first_name' => first_name })
    end

    it 'does not clear properties when errors appeared' do
      described_obj.last_name = Faker::Name.last_name
      described_obj.valid?
      expect(described_obj.first_name).to eq(first_name)
    end

    it 'does not copy properties before validation' do
      described_obj.last_name = Faker::Name.last_name
      expect(described_obj.properties['last_name']).not_to eq(described_obj.last_name)
    end
  end

  describe 'with_status' do
    # rubocop:disable RSpec/BeforeAfterAll
    before(:all) do
      youths = [
        create(:user, :youth, :with_valid_parameters, approved: false), # denied
        create(:user, :youth, :with_valid_parameters, approved: true), # approved
        create(:user, :youth, :with_valid_parameters, approved: false), # pending
        create(:user, :youth, :with_valid_parameters, approved: true) # approved
      ]
      create(:survey, user: youths[0])
      create(:survey, user: youths[1])
    end
    # rubocop:enable RSpec/BeforeAfterAll

    it 'returns all approved users' do
      expect(described_class.with_role('youth').with_status('approved').count).to eq(2)
    end

    it 'returns all pending users' do
      expect(described_class.with_role('youth').with_status('pending').count).to eq(1)
    end

    it 'returns all denied users' do
      expect(described_class.with_role('youth').with_status('denied').count).to eq(1)
    end
  end

  describe '#transgender?' do
    context 'when youth' do
      let(:user) { create(:user, :youth, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.transgender?).to eq(user.transgender == 'yes')
      end
    end

    context 'when host' do
      let(:user) { create(:user, :host, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.transgender?).to eq(user.transgender == 'yes')
      end
    end

    context 'when social worker' do
      let(:user) { create(:user, :social_worker, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.transgender?).to eq(user.transgender == 'yes')
      end
    end
  end

  describe '#ethnicity?' do
    context 'when youth' do
      let(:user) { create(:user, :youth, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.ethnicity?).to eq((user.ethnicities & %w[not_to_respond other]).empty?)
      end
    end

    context 'when host' do
      let(:user) { create(:user, :host, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.ethnicity?).to eq((user.ethnicities & %w[not_to_respond other]).empty?)
      end
    end

    context 'when social worker' do
      let(:user) { create(:user, :social_worker, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.ethnicity?).to eq((user.ethnicities & %w[not_to_respond other]).empty?)
      end
    end
  end

  describe '#gender?' do
    context 'when youth' do
      let(:user) { create(:user, :youth, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.gender?).to eq(%w[not_to_respond other].exclude?(user.gender))
      end
    end

    context 'when host' do
      let(:user) { create(:user, :host, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.gender?).to eq(%w[not_to_respond other].exclude?(user.gender))
      end
    end

    context 'when social worker' do
      let(:user) { create(:user, :social_worker, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.gender?).to eq(%w[not_to_respond other].exclude?(user.gender))
      end
    end
  end

  describe '#pronouns?' do
    context 'when youth' do
      let(:user) { create(:user, :youth, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.pronouns?).to eq(%w[not_to_respond other].exclude?(user.pronouns))
      end
    end

    context 'when host' do
      let(:user) { create(:user, :host, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.pronouns?).to eq(%w[not_to_respond other].exclude?(user.pronouns))
      end
    end

    context 'when social worker' do
      let(:user) { create(:user, :social_worker, :with_valid_parameters) }

      it 'returns correct value' do
        expect(user.pronouns?).to eq(%w[not_to_respond other].exclude?(user.pronouns))
      end
    end
  end
end
