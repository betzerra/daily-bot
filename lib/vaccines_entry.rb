require 'date'
require "time"

class VaccinesEntry
  attr_accessor :last_day, :daily_logs
  attr_writer :first_doses_total, :second_doses_total, :first_doses_last, :second_doses_last

  def initialize(payload)
    entries = payload.flat_map { |i| i[1]['fechas'] }
    @last_day = Time.parse(entries.last['fecha']).to_date.to_s

    days = entries.map { |i| i['fecha'] }.uniq

    @daily_logs = days.map { |day|
      entries_day = entries.filter { |i| i['fecha'] == day }

      day_value = {
        first_doses: entries_day.reduce(0) { |sum, i| sum + i['primeradosis'] }, 
        second_doses: entries_day.reduce(0) { |sum, i| sum + i['segundadosis'] }
      }

      day_key = Time.parse(day).to_date.to_s
      [day_key, day_value]
    }.to_h
  end

  def first_doses_total
    @daily_logs.values.reduce(0) { |sum, i| sum + i[:first_doses] }
  end

  def second_doses_total
    @daily_logs.values.reduce(0) { |sum, i| sum + i[:second_doses] }
  end

  def first_doses_last
    @daily_logs[last_day][:first_doses]
  end

  def second_doses_last
    @daily_logs[last_day][:second_doses]
  end

  private

  def self.entry_date_same_day?(origin, date)
    lhs = Time.parse(origin)
    lhs.to_date === date
  end
end
