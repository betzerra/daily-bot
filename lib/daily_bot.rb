require 'yaml'

require_relative 'dollar_step'
require_relative 'random_gif_step'
require_relative 'random_message_step'
require_relative 'weather_step'
require_relative 'telegram_step'

module DailyBot
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    def reset
      self.configuration = Configuration.new
    end
  end

  class Configuration
    attr_accessor :telegram_token, :telegram_chat_id, :giphy_token,
                  :openweather_token
  end
end
