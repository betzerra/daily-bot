require_relative 'telegram_step'
require_relative 'weather_emoji'

class WeatherStep < TelegramStep
  def handle_step
    text = "*T:* #{temp} #{emoji} (ST: #{feels_like})\n"\
      "MIN: #{temp_min} MAX: #{temp_max}\n"\
      "Humedad: #{humidity}%"

    send_message(text)
  end

  private

  def request_weather
    response = conn.get 'https://api.openweathermap.org/data/2.5/weather'\
                        "?q=#{city}&APPID=#{openweather_token}&units=metric"
    JSON.parse(response.body)
  end

  def format_temp(temp)
    "#{temp}ºC"
  end

  def openweather_token
    configuration.openweather_token
  end

  def city
    payload['city']
  end

  def main_temp
    main['temp']
  end

  def main
    weather['main']
  end

  def weather
    @weather ||= request_weather
  end

  def emoji
    data = weather['weather'].first
    WeatherEmoji.call(data['id'])
  end

  def temp
    format_temp(main_temp)
  end

  def feels_like
    format_temp(main['feels_like'])
  end

  def temp_min
    format_temp(main['temp_min'])
  end

  def temp_max
    format_temp(main['temp_max'])
  end

  def humidity
    main['humidity']
  end
end
