require_relative 'telegram_step'

class DollarStep < TelegramStep
  def handle_step
    text = "*Dolar oficial*: *#{oficial_sell}* / "\
      "*#{oficial_buy}* (spr: *#{spread_oficial}*)\n"\
      "*Dolar blue*: *#{blue_sell}* / "\
      "*#{blue_buy}* (spr: *#{spread_blue}*)\n"\
      "*Dif. blue / oficial:* #{diff_blue_oficial}%\n"\
      "\n"\
      "*Crypto*:\n"\
      "*Dolar naranja*: *#{crypto_sell}* / "\
      "*#{crypto_buy}* (spr: *#{spread_crypto}*)\n"\
      "_(Aproximado, usando precios de Ripio)_\n"\
      "*BTC-ARS*: *#{ripio_btc_ars_formatted}* (Ripio)\n"\
      "*BTC-USD*: *#{coinbase_btc_usd}* (Coinbase) "\
      "*#{ripio_btc_usdc}* (Ripio)\n"\
      "*ETH-USD*: *#{coinbase_eth_usd}* (Coinbase) "\
      "*#{ripio_eth_usdc}* (Ripio)"

    send_message(text, disable_notification)
  end

  private

  def request_dollar
    response = conn.get 'https://api.bluelytics.com.ar/v2/latest'
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
    result = (blue_buy * 100 / oficial_buy) - 100
    result = result.round(2)
    result.positive? ? "⬆️ #{result}" : "⬇️ #{result}"
  end

  # Crypto
  # - Ripio

  def request_crypto_ripio
    response = conn.get 'https://api.exchange.ripio.com/api/v1/rate/all/'
    JSON.parse(response.body)
  end

  def crypto_ripio
    @crypto_ripio ||= request_crypto_ripio
  end

  def ripio_pair(pair)
    crypto_ripio
      .select { |product| product["pair"] == pair }
      .first
  end

  def ripio_btc_usdc
    @ripio_btc_usdc ||= Float(ripio_pair("BTC_USDC")['last_price']) \
      rescue "unknown"
  end

  def ripio_btc_ars
    @ripio_btc_ars ||= Float(ripio_pair("BTC_ARS")['last_price']) \
      rescue "unknown"
  end

  def ripio_btc_ars_formatted
    thousand_format(Integer(ripio_btc_ars)) rescue "unknown"
  end

  def ripio_eth_usdc
    @ripio_eth_usdc ||= Float(ripio_pair("ETH_USDC")['last_price']) \
      rescue "unknown"
  end

  def crypto_buy
    ((ripio_btc_ars / ripio_btc_usdc) * (0.99) ** 2) \
      .round(2) rescue "unknown"
  end

  def crypto_sell
    ((ripio_btc_ars / ripio_btc_usdc) * (1.01) ** 2) \
      .round(2) rescue "unknown"
  end

  def spread_crypto
    (crypto_sell - crypto_buy).round(2) rescue "unknown"
  end

  # - Coinbase

  def request_crypto_coinbase(product)
    response = conn.get "https://api.pro.coinbase.com/products/#{product}/stats"
    JSON.parse(response.body)
  end

  def coinbase_btc_usd
    Float(request_crypto_coinbase('BTC-USD')["last"]) \
      rescue "unknown"
  end

  def coinbase_eth_usd
    Float(request_crypto_coinbase('ETH-USD')["last"]) \
      rescue "unknown"
  end
end
