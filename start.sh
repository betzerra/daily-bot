#!/bin/bash
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ${__dir}
source /home/pi/.rvm/environments/ruby-2.6.2;
bundle exec ruby app.rb
