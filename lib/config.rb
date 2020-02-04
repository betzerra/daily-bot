require 'yaml'

class Config
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def telegram_token
    config['telegram']['token']
  end

  def telegram_chat_id
    config['telegram']['chat_id']
  end

  def steps
    config['script']
  end
end
