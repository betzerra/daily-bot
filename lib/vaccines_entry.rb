require 'date'
require "time"

class VaccinesEntry
    attr_accessor :sum_first_doses, :sum_second_doses, :sum_today_first_doses, :sum_today_second_doses, :last_day

    def initialize(payload)
        entries = payload.flat_map { |i| i[1]["fechas"] }
        @last_day = Time.parse(entries.last['fecha']).to_date

        @sum_first_doses = entries.reduce(0) { |sum, i| sum + i["primeradosis"] }
        @sum_second_doses = entries.reduce(0) { |sum, i| sum + i["segundadosis"] }

        @sum_today_first_doses = entries
                                    .filter { |i| VaccinesEntry.is_entry_date_same_day(i['fecha'], @last_day) }
                                    .reduce(0) { |sum, i| sum + i["primeradosis"] }

        @sum_today_second_doses = entries
                                    .filter { |i| VaccinesEntry.is_entry_date_same_day(i['fecha'], @last_day) }
                                    .reduce(0) { |sum, i| sum + i["segundadosis"] }
    end

    private

    def self.is_entry_date_same_day(origin, date)
        lhs = Time.parse(origin)
        lhs.to_date === date
    end
end
