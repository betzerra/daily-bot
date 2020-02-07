require 'minitest/autorun'

require 'daily_bot'

class StepTest < Minitest::Test
  def config
    @config ||= YAML.load_file(File.join(__dir__, '../config.yml.example'))
  end

  def setup
    DailyBot.configure do |configuration|
      configuration.telegram_token = config['telegram']['token']
      configuration.telegram_chat_id = config['telegram']['chat_id']
      configuration.giphy_token = config['giphy']['token']
      configuration.openweather_token = config['openweather']['token']
    end
  end
end
