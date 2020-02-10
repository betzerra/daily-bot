require_relative 'telegram_step'

class RandomMessageStep < TelegramStep
  def handle_step
    text = payload['messages'].sample

    send_message(text)
  end
end
