require 'test_helper'

class WeatherStepTest < StepTest
  def test_handle_step
    payload = config.steps.find { |step| step['type'] == 'weather' }
    sut = WeatherStep.new(telegram_token, chat_id, payload)

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get('data/2.5/weather') do |req|
      assert_equal 'openweather_token', req.params['APPID']
      assert_equal 'Buenos Aires', req.params['q']

      [
        200,
        { 'Content-Type': 'application/javascript' },
        '{"coord":{"lon":-58.38,"lat":-34.61},"weather":[{"id":801,"main":"Clouds","description":"few clouds","icon":"02d"}],"base":"stations","main":{"temp":33.13,"feels_like":34.72,"temp_min":32,"temp_max":35,"pressure":1011,"humidity":55},"visibility":10000,"wind":{"speed":5.1,"deg":20},"clouds":{"all":20},"dt":1580834096,"sys":{"type":1,"id":8232,"country":"AR","sunrise":1580807784,"sunset":1580857101},"timezone":-10800,"id":3435910,"name":"Buenos Aires","cod":200}'
      ]
    end

    sut.conn = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    expected = "*T:* 33.13ºC 🌤 (ST: 34.72ºC)\nMIN: 32ºC MAX: 35ºC\n"\
      'Humedad: 55%'

    message_info = ->(message) { assert_equal expected, message }

    sut.stub :send_message, message_info, nil do
      sut.handle_step
    end
  end
end
