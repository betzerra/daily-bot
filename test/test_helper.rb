require 'minitest/autorun'
require 'yaml'

require 'config'
require 'dollar_step'
require 'random_gif_step'
require 'random_message_step'
require 'telegram_step'
require 'weather_step'

class StepTest < Minitest::Test
  def config
    @config ||= Config.new(YAML.load_file(File.join(__dir__,
                                                    '../config.yml.example')))
  end

  def telegram_token
    config.telegram_token
  end

  def chat_id
    config.telegram_chat_id
  end
end
