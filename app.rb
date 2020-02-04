require 'yaml'
require 'telegram/bot'

require_relative 'lib/config'
require_relative 'lib/dollar_step'
require_relative 'lib/random_gif_step'
require_relative 'lib/random_message_step'
require_relative 'lib/weather_step'

STEP_CLASSES = {
  'dollar' => DollarStep,
  'random_gif' => RandomGifStep,
  'random_message' => RandomMessageStep,
  'weather' => WeatherStep
}.freeze

config = Config.new(YAML.load_file('config.yml'))

@telegram_token = config.telegram_token
@chat_id = config.telegram_chat_id

def create_object(step_class, payload)
  step_class.new(@telegram_token, @chat_id, payload)
end

steps = config.steps.map do |payload|
  type = payload['type']
  step_class = STEP_CLASSES[type]
  raise "Class not defined for step #{type}" unless step_class

  create_object(step_class, payload)
end

steps.each(&:handle_step)
