# frozen_string_literal: true

require_relative "oort/version"

module Oort
  class << self
    def configuration
      @configuration ||= Oort::Configuration.new
    end

    def configure
      yield configuration
    end
  end
end

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/kamal/sshkit_with_ext.rb")
loader.setup
loader.eager_load # We need all commands loaded.
