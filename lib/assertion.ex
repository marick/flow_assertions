defmodule FlowAssertions.Assertion do

  # Assertions about the behavior of assertions, whee.
  
  import FlowAssertions.Defchain
  import ExUnit.Assertions

  defchain assert_diagnostic(exception, message),
    do: assert exception.message =~ message


  def assertion_fails_with_diagnostic(messages, f) when is_list(messages) do 
    exception = assert_raise(ExUnit.AssertionError, f)

    Enum.map(messages, &(assert_diagnostic exception, &1))
  end

  def assertion_fails_with_diagnostic(message, f), 
    do: assertion_fails_with_diagnostic([message], f)
end
