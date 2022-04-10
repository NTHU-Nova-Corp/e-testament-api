# frozen_string_literal: true

require './app/controllers/app'
require_app

run ETestament::Api.freeze.app
