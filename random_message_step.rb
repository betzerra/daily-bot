require './telegram_step'

class RandomMessageStep < TelegramStep
  def initialize(token, chat_id, payload)
    @payload = payload
    @token = token
    @chat_id = chat_id
  end

  def handle_step
    text = @payload['messages'].sample
    send_message(text)
  end
end
