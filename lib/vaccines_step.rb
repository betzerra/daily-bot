require_relative 'telegram_step'
require_relative 'vaccines_entry'

class VaccinesStep < TelegramStep
  
    def handle_step
        text = "*Primera dosis*: #{vaccines.sum_first_doses} \n"\
            "*Segunda dosis*: #{vaccines.sum_second_doses} \n\n"\
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
end