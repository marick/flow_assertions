defmodule FlowAssertions.AssertionA do

  # Assertions about the behavior of assertions, whee.
  
  import FlowAssertions.Defchain
  import ExUnit.Assertions
  alias FlowAssertions.MapA


  defchain assertion_fails(message, kws \\ [], f) do
    assert_raise(ExUnit.AssertionError, f)
    |> MapA.assert_fields(kws ++ [message: message])
  end

  defchain assertion_fails_for(under_test, left, message, kws \\ []) do
    assert_raise(ExUnit.AssertionError, fn -> under_test.(left) end)
    |> MapA.assert_fields(kws ++ [message: message, left: left])
  end


  ##### OLD

  defchain assert_diagnostic(exception, message),
    do: assert exception.message =~ message


  def assertion_fails_with_diagnostic(messages, f) when is_list(messages) do 
    exception = assert_raise(ExUnit.AssertionError, f)

    Enum.map(messages, &(assert_diagnostic exception, &1))
  end

  def assertion_fails_with_diagnostic(message, f), 
    do: assertion_fails_with_diagnostic([message], f)
end
