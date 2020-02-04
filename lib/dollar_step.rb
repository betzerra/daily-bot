require_relative 'telegram_step'

class DollarStep < TelegramStep
  def request_dollar
    response = conn.get 'http://api.bluelytics.com.ar/v2/latest'
    JSON.parse(response.body)
  end

  def handle_step
    dollar = request_dollar
    spread_oficial = (dollar['oficial']['value_sell'] - dollar['oficial']['value_buy']).round(2)
    spread_blue = (dollar['blue']['value_sell'] - dollar['blue']['value_buy']).round(2)
    text = "*Dolar oficial*: *#{dollar['oficial']['value_sell']}* / "\
      "*#{dollar['oficial']['value_buy']}* (spr: *#{spread_oficial}*)\n"\
      "*Dolar blue*: *#{dollar['blue']['value_sell']}* / "\
      "*#{dollar['blue']['value_buy']}* (spr: *#{spread_blue}*)"

    send_message(text)
  end
end
