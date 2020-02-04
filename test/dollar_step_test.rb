require 'test_helper'

class DollarStepTest < StepTest
  def test_handle_step
    payload = config.steps.find { |step| step['type'] == 'dollar' }

    sut = DollarStep.new(telegram_token, chat_id, payload)

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get('/v2/latest') do
      [
        200,
        { 'Content-Type': 'application/javascript' },
        '{
          "oficial": {
            "value_sell": 63.05,
            "value_buy": 58.05
          },
          "blue": {
            "value_sell": 78,
            "value_buy": 75.27
          }
        }'
      ]
    end

    sut.conn = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    expected = "*Dolar oficial*: *63.05* / *58.05* (spr: *5.0*)\n"\
               '*Dolar blue*: *78* / *75.27* (spr: *2.73*)'

    sut.stub :send_message, ->(message) { assert_equal expected, message } do
      sut.handle_step
    end
  end
end
