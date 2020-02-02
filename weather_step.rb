require 'faraday'

require './telegram_step'

class WeatherStep < TelegramStep
  def initialize(token, chat_id, openweather_token, payload)
    @payload = payload
    @token = token
    @chat_id = chat_id
    @openweather_token = openweather_token
  end

  def request_weather
    response = Faraday.get "https://api.openweathermap.org/data/2.5/weather?q=#{@payload['city']}&APPID=#{@openweather_token}"
    JSON.parse(response.body)
  end

  def weather_emoji(weather)
    # https://openweathermap.org/weather-conditions
    case weather['id']
    when 781 then '🌪' # tornado
    when 511 then '🌨' # freezing rain
    when 200..299 then '⛈' # thunderstorm
    when 300..399 then '🌧' # drizzle
    when 500..599 then '🌧' # rain
    when 600..699 then '❄️' # snow
    when 700..799 then '🌫' # atmosphere
    when 800 then '☀️' # clear
    when 801 then '🌤' # few clouds
    when 802..803 then '⛅️' # scattered clouds
    when 804..899 then '☁️' # clouds
    else '🤷'
    end
  end

  def format_temp(t)
    "#{(t / 10).round(2)}ºC"
  end

  def handle_step
    weather = request_weather

    emoji = weather_emoji(weather['weather'].first)
    temp = format_temp(weather['main']['temp'])
    feels_like = format_temp(weather['main']['feels_like'])
    temp_min = format_temp(weather['main']['temp_min'])
    temp_max = format_temp(weather['main']['temp_max'])
    humidity = format_temp(weather['main']['humidity'])

    text = "*T:* #{temp} #{emoji} (ST: #{feels_like})\n"\
      "MIN: #{temp_min} MAX: #{temp_max}\n"\
      "Humedad: #{humidity}%"

    send_message(text)
  end
end
