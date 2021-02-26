require_relative 'telegram_step'
require_relative 'vaccines_entry'

class VaccinesStep < TelegramStep
  
    def handle_step
        text = "*Vacunaciones contra COVID-19 en Argentina* 💉 \n"\
            "*- Primera dosis*: #{thousand_format(vaccines.sum_first_doses)} "\
            "#{today_doses(vaccines.sum_today_first_doses)}\n"\
            "*- Segunda dosis*: #{thousand_format(vaccines.sum_second_doses)} "\
            "#{today_doses(vaccines.sum_today_second_doses)}\n\n"\
            "*Última actualización:* #{last_day} "\
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

    def last_day
        vaccines.last_day.strftime('%d-%m-%Y')
    end

    def today_doses(number)
        return if number.zero?

        "(+#{thousand_format(number)})"
    end
end