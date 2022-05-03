# frozen_string_literal: true

# Unauthorized exception
class UnauthorizedException < StandardError
  def initialize(msg = 'Unauthorized', exception_type = 'custom')
    @exception_type = exception_type
    @status_code = 401
    super(msg)
  end
end
