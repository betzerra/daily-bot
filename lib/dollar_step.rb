require_relative 'telegram_step'

class DollarStep < TelegramStep
  def handle_step
    text = "*Dolar oficial*: *#{oficial_sell}* / "\
      "*#{oficial_buy}* (spr: *#{spread_oficial}*)\n"\
      "*Dolar blue*: *#{blue_sell}* / "\
      "*#{blue_buy}* (spr: *#{spread_blue}*)\n"\
      "*Dif. blue / oficial:* #{diff_blue_oficial}%"

    send_message(text)
  end

  private

  def request_dollar
    response = conn.get 'http://api.bluelytics.com.ar/v2/latest'
    JSON.parse(response.body)
  end

  def dollar
    @dollar ||= request_dollar
  end

  def blue
    @blue ||= dollar['blue']
  end

  def oficial
    @oficial ||= dollar['oficial']
  end

  def spread_oficial
    (oficial_sell - oficial_buy).round(2)
  end

  def spread_blue
    (blue_sell - blue_buy).round(2)
  end

  def oficial_buy
    oficial['value_buy']
  end

  def oficial_sell
    oficial['value_sell']
  end

  def blue_sell
    blue['value_sell']
  end

  def blue_buy
    blue['value_buy']
  end

  def diff_blue_oficial
    result = (blue_buy * 100 / oficial_buy).round(2) - 100
    result.positive? ? "⬆️ #{result}" : "⬇️ #{result}"
  end
end
