require_relative 'lib/daily_bot'

STEP_CLASSES = {
  'covid' => CovidStep,
  'dollar' => DollarStep,
  'random_gif' => RandomGifStep,
  'random_message' => RandomMessageStep,
  'squanchy_message' => SquanchyMessageStep,
  'vaccines' => VaccinesStep,
  'weather' => WeatherStep,
  'weather_forecast' => WeatherForecastStep
}.freeze

config_filename = ARGV.first || 'config.yml'

config_hash = YAML.load_file(config_filename)

DailyBot.configure do |config|
  config.telegram_token = config_hash['telegram']['token']
  config.telegram_chat_id = config_hash['telegram']['chat_id']
  config.giphy_token = config_hash['giphy']['token']
  config.openweather_token = config_hash['openweather']['token']
end

steps = config_hash['script'].map do |payload|
  type = payload['type']
  step_class = STEP_CLASSES[type]
  raise "Class not defined for step #{type}" unless step_class

  step_class.new(payload)
end

steps.each(&:handle_step)
