require 'json'
require 'yaml'

require 'telegram/bot'

require_relative 'lib/dollar_step'
require_relative 'lib/random_gif_step'
require_relative 'lib/random_message_step'
require_relative 'lib/weather_step'

config = YAML.load_file('config.yml')

telegram_token = config['telegram']['token']
chat_id = config['telegram']['chat_id']

steps = config['script'].map do |i|
  case i['type']
  when 'dollar'
    DollarStep.new(telegram_token, chat_id, i)
  when 'random_gif'
    RandomGifStep.new(telegram_token, chat_id, i)
  when 'random_message'
    RandomMessageStep.new(telegram_token, chat_id, i)
  when 'weather'
    WeatherStep.new(telegram_token, chat_id, i)
  end
end

steps.each do |i|
  i.handle_step
end
