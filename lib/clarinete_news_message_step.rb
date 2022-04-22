require_relative 'telegram_step'
require 'json'

class ClarineteNewsMessageStep < TelegramStep
  def handle_step
    news = formatted_trends.join("\n\n")
    message = "Aquí están las últimas noticias del día: \n\n#{news}"
    send_message(message, disable_notification)
  end

  private

  def formatted_trends
    trends.take(5).map do |trend|
      "- *#{trend['name']}:* #{trend['title']} [link](#{trend['url']})"
    end
  end

  def trends
    @trends ||= refine_trends(request_trends)
  end

  def refine_trends(trends)
    seen = []
    results = []
    trends.each do |item|
      unless seen.include? item['name']
        results.append item
        seen.append item['name']
      end
      seen.append(*item['related_topics'])
    end

    results
  end

  def request_trends
    response = conn.get 'https://clarinete.seppo.com.ar/api/trends'
    JSON.parse(response.body)
  end
end