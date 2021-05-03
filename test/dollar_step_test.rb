require 'test_helper'

class DollarStepTest < StepTest
  def stub_bluelytics(stubs)
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
  end

  def stub_ripio(stubs)
    stubs.get('/api/v1/rate/all/') do
      [
        200,
        { 'Content-Type': 'application/javascript' },
        '[
          {"pair":"BTC_USDC", "last_price":"54321.00"},
          {"pair":"ETH_USDC", "last_price":"12345.00"}, 
          {"pair":"BTC_ARS", "last_price":"123456789.00"}
        ]'  
      ]
    end
  end

  def stub_coinbase(stubs, product, price)
    stubs.get("/products/#{product}/stats") do
      [
        200,
        { 'Content-Type': 'application/javascript' },
        "{\"last\":\"#{price}\"}"
      ]
    end
  end

  def test_handle_step
    payload = config['script'].find { |step| step['type'] == 'dollar' }

    sut = DollarStep.new(payload)

    stubs = Faraday::Adapter::Test::Stubs.new
    stub_bluelytics(stubs)
    stub_ripio(stubs)
    stub_coinbase(stubs, "BTC-USD", 54320.12)
    stub_coinbase(stubs, "ETH-USD", 12346.17)

    sut.conn = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    expected = "*Dolar oficial*: *63.05* / *58.05* (spr: *5.0*)\n"\
               "*Dolar blue*: *78* / *75.27* (spr: *2.73*)\n"\
               "*Dif. blue / oficial:* ⬆️ 29.66%\n"\
               "\n"\
               "*Crypto*:\n"\
               "*Dolar naranja*: *2318.41* / *2227.5* (spr: *90.91*)\n"\
               "_(Aproximado, usando precios de Ripio)_\n"\
               "*BTC-ARS*: *123.456.789* (Ripio)\n"\
               "*BTC-USD*: *54320.12* (Coinbase) *54321.0* (Ripio)\n"\
               '*ETH-USD*: *12346.17* (Coinbase) *12345.0* (Ripio)'

    sut.stub :send_message, ->(message) { assert_equal expected, message } do
      sut.handle_step
    end
  end

  def test_handle_step_failed_request
    payload = config['script'].find { |step| step['type'] == 'dollar' }

    sut = DollarStep.new(payload)

    stubs = Faraday::Adapter::Test::Stubs.new
    stub_bluelytics(stubs)

    stubs.get('/api/v1/rate/all/') do
      [500, {}, '{}']
    end

    stubs.get(/\/products\/(.*?)\/stats/) do
      [500, {}, '{}']
    end

    sut.conn = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    expected = "*Dolar oficial*: *63.05* / *58.05* (spr: *5.0*)\n"\
               "*Dolar blue*: *78* / *75.27* (spr: *2.73*)\n"\
               "*Dif. blue / oficial:* ⬆️ 29.66%\n"\
               "\n"\
               "*Crypto*:\n"\
               "*Dolar naranja*: *unknown* / *unknown* (spr: *unknown*)\n"\
               "_(Aproximado, usando precios de Ripio)_\n"\
               "*BTC-ARS*: *unknown* (Ripio)\n"\
               "*BTC-USD*: *unknown* (Coinbase) *unknown* (Ripio)\n"\
               '*ETH-USD*: *unknown* (Coinbase) *unknown* (Ripio)'

    sut.stub :send_message, ->(message) { assert_equal expected, message } do
      sut.handle_step
    end
  end
end
