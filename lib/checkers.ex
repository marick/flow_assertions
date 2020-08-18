defmodule FlowAssertions.Checkers do
  alias FlowAssertions.Define.Defchecker.Failure

  @moduledoc """
  Functions that create handy predicates for use with `FlowAssertions.MiscA.assert_good_enough/2`
  """

  @doc """
  TBD
  """

  def _in_any_order(_expected) do
  end

  @doc """
  TBD
  """
  def contains(expected) when is_binary(expected) do
    fn actual ->
      if String.contains?(actual, expected),
        do: true,
        else: Failure.new(mfa: {__MODULE__, :contains, [expected]}, actual: actual)
    end
  end
end  
