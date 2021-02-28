require 'faraday'
require 'faraday_middleware'
require 'telegram/bot'

class TelegramStep
  attr_writer :conn

  def initialize(payload)
    @token = configuration.telegram_token
    @chat_id = configuration.telegram_chat_id
    @payload = payload
  end

  def conn
    @conn ||= Faraday.new do |f|
      f.use FaradayMiddleware::FollowRedirects
    end
  end

  def configuration
    @configuration ||= DailyBot.configuration
  end

  private

  attr_reader :token, :chat_id, :payload

  def send_message(text)
    Telegram::Bot::Client.run(token) do |bot|
      bot.api.send_message(
        chat_id: chat_id,
        text: text,
        parse_mode: 'markdown',
        disable_web_page_preview: true
      )
    end
  end

  def send_gif(url)
    Telegram::Bot::Client.run(token) do |bot|
      bot.api.send_animation(
        chat_id: chat_id,
        animation: url,
        disable_notification: true
      )
    end
  end

  def send_image(path, caption)
    # TODO: Support more image MIME types

    Telegram::Bot::Client.run(token) do |bot|
      bot.api.send_photo(
        chat_id: chat_id,
        photo: Faraday::UploadIO.new(path, 'image/jpeg'),
        caption: caption
      )
    end
  end

  def thousand_format(number)
    number.to_s.reverse.gsub(/...(?=.)/,'\&.').reverse
  end
end
