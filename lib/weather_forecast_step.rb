require_relative 'telegram_step'
require_relative 'weather_emoji'
require_relative 'weather_entry'

class WeatherForecastStep < TelegramStep

  WEATHER_ITEMS = 4

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
    entries = weather['list'].take(WEATHER_ITEMS).map { |i| WeatherEntry.new(i) }

    sample = entries.first
    new_entries = [sample]
    entries.each do |i|
      if sample.quite_similar?(i)
        sample.merge(i)
      else
        sample = i
        new_entries << i
      end
    end

    new_entries.inject('') do |t, i|
      t << "#{i.text}\n"
    end
  end

  def forecast_min
    min = weather['list'].take(WEATHER_ITEMS).map { |i| i['main']['temp_min'] }.min
    format_temp(min)
  end

  def forecast_max
    max = weather['list'].take(WEATHER_ITEMS).map { |i| i['main']['temp_max'] }.max
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
