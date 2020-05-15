require_relative 'telegram_step'
require 'nokogiri'

class CovidStep < TelegramStep
  def handle_step
    text = "*Reporte de COVID-19 en #{payload['country'].capitalize} 🦠*\n"\
      "- Contagiados: #{total_cases}\n"\
      "- Muertos: #{deaths}\n"\
      "- Recuperados: #{recovered}\n"\
      "- Activos: #{active}\n"\
      "- En grave estado: #{serious}\n"\
      "- Testeados: #{total_tests}\n"

    send_message(text)
  end

  private

  def request_covid_data
    response = conn.get 'https://www.worldometers.info/coronavirus/'
    Nokogiri::HTML(response.body)
  end

  def covid_page
    @covid_page ||= request_covid_data
  end

  def country
    country_code = "country/#{payload['country']}/"

    @country ||= covid_page
                 .css('.mt_a')
                 .select { |i| i['href'] == country_code }
                 .first
                 .parent
                 .parent
  end

  def total_cases
    country.css('td')[2].text.tr(',', '.')
  end

  def deaths
    country.css('td')[4].text.tr(',', '.')
  end

  def recovered
    country.css('td')[6].text.tr(',', '.')
  end

  def active
    country.css('td')[7].text.tr(',', '.')
  end

  def serious
    country.css('td')[8].text.tr(',', '.')
  end

  def total_tests
    country.css('td')[11].text.tr(',', '.')
  end
end
