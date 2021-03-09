require 'minitest/autorun'
require 'date'
require 'json'

require 'daily_bot'

class VaccinesEntryTest < Minitest::Test
  def payload
    vaccines = File.read(File.join(__dir__, ('fixtures/vaccines.json')))
    JSON.parse(vaccines)
  end

  def setup

  end

  def test_entry
    entry = VaccinesEntry.new(payload)

    # total
    assert_equal 119705, entry.first_doses_total
    assert_equal 1399, entry.second_doses_total

    # last entries
    assert_equal 2826, entry.first_doses_last
    assert_equal 661, entry.second_doses_last
  end

  def test_date_parsing
    assert VaccinesEntry.entry_date_same_day?(
      '2021-01-19T00:00:00-03:00',
      Date.new(2021, 1, 19)
    )

    assert !VaccinesEntry.entry_date_same_day?(
      '2021-01-19T00:00:00-03:00',
      Date.new(2021, 1, 18)
    )
  end
end
