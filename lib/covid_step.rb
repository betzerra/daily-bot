require_relative 'telegram_step'
require 'nokogiri'

class CovidStep < TelegramStep
  def handle_step
    new_cases = daily_cases.nil? ? "" : "(#{daily_cases})"
    new_deaths = daily_deaths.nil? ? "" : "(#{daily_deaths})"

    text = "*Reporte de COVID-19 en #{payload['country'].capitalize} 🦠*\n"\
      "- Contagiados: #{total_cases} #{new_cases}\n"\
      "- Ranking Contagiados: \##{ranking}\n"\
      "- Muertos: #{deaths} #{new_deaths}\n"\
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

  def daily_cases
    country.css('td')[3].text.tr(',', '.')
  end

  def deaths
    country.css('td')[4].text.tr(',', '.')
  end

  def daily_deaths
    country.css('td')[5].text.tr(',', '.')
  end

  def total_tests
    country.css('td')[12].text.tr(',', '.')
  end

  def ranking
    country.css('td')[0].text.tr(',', '.')
  end
end
