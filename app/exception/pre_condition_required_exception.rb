# frozen_string_literal: true

# Bad request exception
class PreConditionRequireException < StandardError
  def initialize(msg = 'Pre condition required', exception_type = 'custom')
    @exception_type = exception_type
    @status_code = 428
    super(msg)
  end
end
