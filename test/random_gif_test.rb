require 'test_helper'

class RandomGifStepTest < StepTest
  def test_handle_step
    payload = config['script'].find { |step| step['type'] == 'random_gif' }

    sut = RandomGifStep.new(payload)

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

    mock = Minitest::Mock.new
    mock.expect :call, nil, ['http://foo.gif']

    sut.stub :send_gif, mock do
      sut.handle_step
    end

    assert_mock mock
  end
end
