require 'gruff'
require_relative 'telegram_step'
require_relative 'vaccines_entry'

class VaccinesGraphStep < TelegramStep
  
    def handle_step
        # get only last 2 weeks
        data = vaccines.daily_logs.to_a.last(14).to_h
        
        g = Gruff::Line.new

        g.title = "Vacunaciones #{data.keys.first} a #{data.keys.last}"
        g.data '1 Dosis', data.map { |_, v| v[:first_doses] }
        g.data '2 Dosis', data.map { |_, v| v[:second_doses] }

        g.write('stuff_4.png')
    end

    def request_vaccines
        response = conn.get 'https://covidstats.com.ar/ws/vacunados'
        JSON.parse(response.body)
    end

    def vaccines
        @vaccines ||= VaccinesEntry.new(request_vaccines)
    end
end