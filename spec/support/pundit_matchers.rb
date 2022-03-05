# frozen_string_literal: true

RSpec::Matchers.define :permit do |user, record, action|
  match do |policy|
    policy.new(user, record).public_send(action)
  end

  failure_message do |policy|
    "Expected #{policy} to permit #{action} on #{record} but it didn't."
  end

  failure_message_when_negated do |policy|
    "Expected #{policy} to forbid #{action} on #{record} but it didn't."
  end
end
