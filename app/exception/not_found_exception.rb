# frozen_string_literal: true

# Bad request exception
class NotFoundException < StandardError
  def initialize(msg = 'Not found', exception_type = 'custom')
    @exception_type = exception_type
    @status_code = 404
    super(msg)
  end
end
