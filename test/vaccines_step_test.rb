require 'test_helper'

class VaccinesStepTest < StepTest
  def test_handle_step
    payload = config['script'].find { |step| step['type'] == 'vaccines' }

    sut = VaccinesStep.new(payload)

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get('/ws/vacunados') do
      [
        200,
        { 'Content-Type': 'application/javascript' },
        '{
            "6": {
                "denominacion": "Buenos Aires",
                "poblacion": 17541141,
                "fechas": [{
                    "fecha": "2021-01-19T00:00:00-03:00",
                    "tipovacuna": "Sputnik V COVID19 Instituto Gamaleya",
                    "primeradosis": 93507,
                    "segundadosis": 77
                }]
            },
            "2": {
                "denominacion": "CABA",
                "poblacion": 3075646,
                "fechas": [{
                    "fecha": "2021-01-19T00:00:00-03:00",
                    "tipovacuna": "Sputnik V COVID19 Instituto Gamaleya",
                    "primeradosis": 23372,
                    "segundadosis": 661
                }]
            }
        }'
      ]
    end

    sut.conn = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    expected = "*Primera dosis*: 116879 \n"\
               "*Segunda dosis*: 738 \n\n"\
               '[Fuente](https://covidstats.com.ar/vacunados)'

    sut.stub :send_message, ->(message) { assert_equal expected, message } do
      sut.handle_step
    end
  end
end
