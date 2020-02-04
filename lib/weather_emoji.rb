module WeatherEmoji
  def self.call(id)
    # https://openweathermap.org/weather-conditions
    case id
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
end
