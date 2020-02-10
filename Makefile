TEST := test/*_test.rb

.PHONY: test

test:
	@ruby -I lib:test -e 'ARGV.each { |f| require "./#{f}" }' $(TEST)
