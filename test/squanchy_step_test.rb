require 'test_helper'

class SquanchyStepTest < StepTest
  def stub_squanchy_message(stubs)
    stubs.get('/posts/random') do
      [
        200,
        { 'Content-Type': 'application/javascript' },
        '{
          "id":5,
          "content": "Hello World",
          "created_at":"2022-01-16T19:31:47.030Z",
          "updated_at":"2022-01-16T19:31:47.030Z"
        }'
      ]
    end
  end

  def test_handle_step
    payload = config['script'].find { |step| step['type'] == 'squanchy' }

    sut = SquanchyMessageStep.new(payload)

    stubs = Faraday::Adapter::Test::Stubs.new
    stub_squanchy_message(stubs)

    sut.conn = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    expected = "Hello World"

    sut.stub :send_message, ->(message, _) { assert_equal expected, message } do
      sut.handle_step
    end
  end
end
