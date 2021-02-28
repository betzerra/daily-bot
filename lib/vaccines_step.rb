require_relative 'telegram_step'
require_relative 'vaccines_entry'

class VaccinesStep < TelegramStep
  
    def handle_step
        text = "*Vacunaciones contra COVID-19 en Argentina* 💉 \n"\
            "*- Primera dosis*: #{thousand_format(vaccines.first_doses_total)} "\
            "#{today_doses(vaccines.first_doses_last)}\n"\
            "*- Segunda dosis*: #{thousand_format(vaccines.second_doses_total)} "\
            "#{today_doses(vaccines.second_doses_last)}\n\n"\
            "*Última actualización:* #{vaccines.last_day} \n"\
            "[Fuente](https://covidstats.com.ar/vacunados)"

        send_message(text)
    end

    def request_vaccines
        response = conn.get 'https://covidstats.com.ar/ws/vacunados'
        JSON.parse(response.body)
    end

    def vaccines
        @vaccines ||= VaccinesEntry.new(request_vaccines)
    end

    def today_doses(number)
        return if number.zero?

        "(+#{thousand_format(number)})"
    end
end