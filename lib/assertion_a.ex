defmodule FlowAssertions.AssertionA do
  
  @moduledoc """
  Assertions used to test other assertions.
  """
  
  import ExUnit.Assertions
  alias ExUnit.AssertionError
  import FlowAssertions.Define.Defchain
  alias FlowAssertions.MapA

  @doc """
  TBD
  """
  defchain assertion_fails(message, kws \\ [], f) do
    assert_raise(AssertionError, f)
    |> MapA.assert_fields(kws ++ [message: message])
  end

  @doc """
  TBD
  """
  defchain assertion_fails_for(under_test, left, message, kws \\ []) do
    assert_raise(AssertionError, fn -> under_test.(left) end)
    |> MapA.assert_fields(kws ++ [message: message, left: left])
  end


  ##### OLD

  @doc false
  defchain assert_diagnostic(exception, message),
    do: assert exception.message =~ message


  @doc false
  def assertion_fails_with_diagnostic(messages, f) when is_list(messages) do 
    exception = assert_raise(AssertionError, f)

    Enum.map(messages, &(assert_diagnostic exception, &1))
  end

  @doc false
  def assertion_fails_with_diagnostic(message, f), 
    do: assertion_fails_with_diagnostic([message], f)
end
