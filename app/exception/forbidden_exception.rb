# frozen_string_literal: true

# Unauthorized exception
class ForbiddenException < StandardError
  def initialize(msg = 'Forbidden', exception_type = 'custom')
    @exception_type = exception_type
    @status_code = 403
    super(msg)
  end
end
