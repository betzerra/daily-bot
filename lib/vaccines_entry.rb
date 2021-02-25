class VaccinesEntry
    attr_accessor :sum_first_doses, :sum_second_doses

    def initialize(payload)
        entries = payload.flat_map { |i| i[1]["fechas"] }

        @sum_first_doses = entries.reduce(0) { |sum, i| sum + i["primeradosis"] }
        @sum_second_doses = entries.reduce(0) { |sum, i| sum + i["segundadosis"] }
    end
end
