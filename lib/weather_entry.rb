require_relative 'weather_emoji'

class WeatherEntry
  attr_accessor :min_temp, :max_temp, :temp, :feels_like, :emoji, :timestamp_begin, :timestamp_end

  TEMPERATURE_THRESHOLD = 2.0

  def initialize(payload)
    @min_temp = payload['main']['temp_min']
    @max_temp = payload['main']['temp_max']
    @temp = payload['main']['temp']
    @feels_like = payload['main']['feels_like']
    @emoji = WeatherEmoji.call(payload['weather'].first['id'])
    @timestamp_begin = payload['dt']
    @timestamp_end = payload['dt']
  end

  def quite_similar?(another_entry)
    if (temp - another_entry.temp).abs <= TEMPERATURE_THRESHOLD &&
       emoji == another_entry.emoji

      true
    else
      false
    end
  end

  def merge(another_entry)
    @min_temp = [min_temp, another_entry.min_temp].min
    @max_temp = [max_temp, another_entry.max_temp].max
    @timestamp_begin = [timestamp_begin, another_entry.timestamp_begin].min
    @timestamp_end = [timestamp_end, another_entry.timestamp_end].max
  end

  def text
    "*#{display_time}* #{emoji} #{format_temp(temp)}"
  end

  def display_time
    if timestamp_begin == timestamp_end
      Time.at(timestamp_begin).strftime('%I%p')
    else
      "#{Time.at(timestamp_begin).strftime('%I%p')} - #{Time.at(timestamp_end).strftime('%I%p')}"
    end
  end

  def format_temp(temp)
    "#{temp}ºC"
  end
end
