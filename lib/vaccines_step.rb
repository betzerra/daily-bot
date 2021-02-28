require 'gruff'

require_relative 'telegram_step'
require_relative 'vaccines_entry'

class VaccinesStep < TelegramStep
  
    GRAPH_FILENAME = 'vaccines_graph.jpg'

    def handle_step
        text = "*Vacunaciones contra COVID-19 en Argentina* 💉 \n"\
            "*- Primera dosis*: #{thousand_format(vaccines.first_doses_total)} "\
            "#{today_doses(vaccines.first_doses_last)}\n"\
            "*- Segunda dosis*: #{thousand_format(vaccines.second_doses_total)} "\
            "#{today_doses(vaccines.second_doses_last)}\n\n"\
            "*Última actualización:* #{vaccines.last_day} \n"\
            "[Fuente](https://covidstats.com.ar/vacunados)"

        send_message(text)

        send_graph
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

    private

    def send_graph
        # get only last 2 weeks
        data = vaccines.daily_logs.to_a.last(14).to_h
        title = "Vacunaciones: #{data.keys.first} a #{data.keys.last}"

        g = Gruff::Line.new

        g.title = title
        g.data '1 Dosis', data.map { |_, v| v[:first_doses] }
        g.data '2 Dosis', data.map { |_, v| v[:second_doses] }

        g.write(GRAPH_FILENAME)
        send_image(GRAPH_FILENAME, title)
    end
end