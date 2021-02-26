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
    assert_equal 119705, entry.sum_first_doses
    assert_equal 1399, entry.sum_second_doses
  end

  def test_date_parsing
    assert VaccinesEntry.is_entry_date_same_day(
      '2021-01-19T00:00:00-03:00',
      Date.new(2021,1,19)
    )

    assert !VaccinesEntry.is_entry_date_same_day(
      '2021-01-19T00:00:00-03:00',
      Date.new(2021,1,18)
    )
  end
end
