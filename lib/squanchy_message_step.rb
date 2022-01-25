require_relative 'telegram_step'

class SquanchyMessageStep < TelegramStep
  def handle_step
    response = conn.get 'https://squanchy.dokku.betzerra.dev/posts/random'
    json = JSON.parse(response.body)

    send_message(json['content'])
  end
end