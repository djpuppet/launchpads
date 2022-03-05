# frozen_string_literal: true

module Properties
  # Cover original hash class with Options class to allow usage of Procs and lambdas
  # This is due to the fact that the properties hash is called on the Rails app initialization
  # There is no database connection at that moment.
  # If records from DB are required we have to delay the query (by passing a Proc)

  class Options < Hash
    def [](key)
      store(key, fetch(key).call) if fetch(key, nil).is_a?(Proc)

      super
    end
  end
end
