require_relative 'telegram_step'
require_relative 'weather_emoji'

class WeatherForecastStep < TelegramStep
  def handle_step
    text = forecast
    text << "MIN: #{forecast_min} MAX: #{forecast_max}"

    send_message(text)
  end

  private

  def request_weather
    response = conn.get 'https://api.openweathermap.org/data/2.5/forecast?'\
                        "lat=#{lat}&lon=#{lon}"\
                        "&APPID=#{openweather_token}&units=metric"
    JSON.parse(response.body)
  end

  def forecast
    weather['list'].take(3).inject('') do |t, i|
      t << "#{forecast_item(i)}\n"
    end
  end

  def forecast_item(entry)
    time = Time.at(entry['dt']).strftime('%I%p')
    "*#{time}* #{WeatherEmoji.call(entry['weather'].first['id'])} "\
    "#{format_temp(entry['main']['temp'])}"
  end

  def forecast_min
    min = weather['list'].take(3).map { |i| i['main']['temp_min'] }.min
    format_temp(min)
  end

  def forecast_max
    max = weather['list'].take(3).map { |i| i['main']['temp_max'] }.max
    format_temp(max)
  end

  def format_temp(temp)
    "#{temp}ºC"
  end

  def openweather_token
    configuration.openweather_token
  end

  def lat
    payload['lat']
  end

  def lon
    payload['lon']
  end

  def weather
    @weather ||= request_weather
  end
end
