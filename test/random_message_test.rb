require 'test_helper'

class RandomMessageStepTest < StepTest
  def test_handle_step
    payload = config['script'].find { |step| step['type'] == 'random_message' }

    sut = RandomMessageStep.new(payload)

    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.get('/v1/gifs/random') do |req|
      assert_equal 'giphy_token', req.params['api_key']
      assert_includes %w[morning hello], req.params['tag']

      [
        200,
        { 'Content-Type': 'application/javascript' },
        '{"data":{"image_url":"http://foo.gif"}}'
      ]
    end

    sut.conn = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    message_info = ->(message) { assert_includes payload['messages'], message }

    sut.stub :send_message, message_info, nil do
      sut.handle_step
    end
  end
end
