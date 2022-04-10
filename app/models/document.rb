# frozen_string_literal: true

require 'json'
require 'sequel'

module ETestament
  # Models a document related with a Property
  class Document < Sequel::Model
    many_to_one :property

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'document',
            attributes: {
              id:,
              file_name:,
              relative_path:,
              description:,
              content:
            }
          },
          included: {
            property:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end