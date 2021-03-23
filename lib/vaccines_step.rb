require 'gruff'

require_relative 'telegram_step'
require_relative 'vaccines_entry'

class VaccinesStep < TelegramStep
  GRAPH_FILENAME = 'vaccines_graph.jpg'

  def handle_step
    if text_summary_enabled
      text = "*Vacunaciones contra COVID-19 en Argentina* 💉 \n"\
        "*- Primera dosis*: #{thousand_format(vaccines.first_doses_total)} "\
        "#{today_doses(vaccines.first_doses_last)}\n"\
        "*- Segunda dosis*: #{thousand_format(vaccines.second_doses_total)} "\
        "#{today_doses(vaccines.second_doses_last)}\n\n"\
        "*Última actualización:* #{vaccines.last_day} \n"\
        '[Fuente](https://covidstats.com.ar/vacunados)'

      send_message(text)
    end

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
    data = vaccines.daily_logs.to_a.last(graph_period_days).to_h
    title = "Vacunaciones: #{data.keys.first} a #{data.keys.last}"

    g = Gruff::Line.new

    g.title = title
    g.data '1 Dosis', (data.map { |_, v| v[:first_doses] })
    g.data '2 Dosis', (data.map { |_, v| v[:second_doses] })

    g.marker_font_size = 18
    g.labels = data
                .keys
                .map
                .with_index do |key, i|
                  label = (i % graph_labels_interval).zero? ? short_date(key) : ''
                  [i, label]
                end
                .to_h

    g.write(GRAPH_FILENAME)
    send_photo(GRAPH_FILENAME, title)
  end

  def short_date(value)
    Date.strptime(value, '%Y-%m-%d').strftime('%m-%d')
  end

  def graph_period_days
    payload['graph_period_days']
  end

  def text_summary_enabled
    payload['text_summary_enabled']
  end

  def graph_labels_interval
    payload['graph_labels_interval'] || 1
  end
end
