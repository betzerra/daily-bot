require 'minitest/autorun'
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
end
