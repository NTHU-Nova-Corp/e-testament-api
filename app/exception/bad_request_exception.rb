# frozen_string_literal: true

# Bad request exception
class BadRequestException < StandardError
  def initialize(msg = 'Bad request', exception_type = 'custom')
    @exception_type = exception_type
    super(msg)
  end
end
