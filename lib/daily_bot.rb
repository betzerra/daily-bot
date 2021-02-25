require 'yaml'
require 'ostruct'

require_relative 'covid_step'
require_relative 'dollar_step'
require_relative 'random_gif_step'
require_relative 'random_message_step'
require_relative 'weather_step'
require_relative 'weather_forecast_step'
require_relative 'telegram_step'
require_relative 'vaccines_entry'

module DailyBot
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= OpenStruct.new
      yield(configuration)
    end

    def reset
      self.configuration = OpenStruct.new
    end
  end
end
