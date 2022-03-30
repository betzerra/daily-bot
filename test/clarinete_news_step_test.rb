require 'test_helper'

class ClarineteNewsStepTest < StepTest
  def stub_trends(stubs)
    stubs.get('/api/trends') do
      [
        200,
        { 'Content-Type': 'application/javascript' },
        '[
          {
            "id": 23416124,
            "name": "Will Smith",
            "related_topics": [
              "Smith"
            ],
            "title": "Qué es la afección que padece Jada Pinkett, por la que Will Smith golpeó a Chris Rock",
            "url": "https://clarin.com/foo"
          },
          {
            "id": 6269,
            "name": "el Gobierno",
            "related_topics": [],
            "title": "Carlos Melconian: “La inflación es socia del Gobierno”",
            "url": "https://clarin.com/bar"
          },
          {
            "id": 19699,
            "name": "Qatar",
            "related_topics": [],
            "title": "Salah, fuera del Mundial: Sané y Senegal clasificaron a Qatar 2022",
            "url": "https://clarin.com/baz"
          }
        ]'
      ]
    end
  end

  def test_handle_step
    payload = config['script'].find { |step| step['type'] == 'clarinete_news' }

    sut = ClarineteNewsMessageStep.new(payload)

    stubs = Faraday::Adapter::Test::Stubs.new
    stub_trends(stubs)

    sut.conn = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    expected = "Aquí están las últimas noticias del día: \n\n"\
    "- *Will Smith:* Qué es la afección que padece Jada Pinkett, por la que Will Smith golpeó a Chris Rock [link](https://clarin.com/foo)\n\n"\
    "- *el Gobierno:* Carlos Melconian: “La inflación es socia del Gobierno” [link](https://clarin.com/bar)\n\n"\
    "- *Qatar:* Salah, fuera del Mundial: Sané y Senegal clasificaron a Qatar 2022 [link](https://clarin.com/baz)"

    sut.stub :send_message, ->(message, _) { assert_equal expected, message } do
      sut.handle_step
    end
  end
end
