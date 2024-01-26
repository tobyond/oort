# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "oort"

require "active_record"
require "minitest/autorun"

connection_options = { adapter: "postgresql" }
database = "oort"
ActiveRecord::Base.establish_connection(connection_options)
begin
  ActiveRecord::Base.connection.create_database(database)
rescue ActiveRecord::StatementInvalid
  puts "db already exists ..."
end
ActiveRecord::Base.establish_connection(connection_options.merge(database:))

def teardown_db
  %w[posts users].each do |table|
    next unless ActiveRecord::Base.connection.data_source_exists?(table)

    ActiveRecord::Base.connection.drop_table(table)
  end
end

def assert_nothing_raised
  yield.tap { assert(true) }
rescue StandardError => e
  raise Minitest::UnexpectedError, e
end
