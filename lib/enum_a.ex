defmodule FlowAssertions.EnumA do
  import FlowAssertions.Defchain
  import ExUnit.Assertions

  @doc """
  Assert that any Enum has only a single element.
  ```
  [1] |> assert_singleton   # passes
  [ ] |> assert_singleton   # fails

  %{a: 1} |> assert_singleton       # passes
  %{a: 1, b: 2} |> assert_singleton # fails
  ```
  """

  defchain assert_singleton(value_to_check),
    do: singleton_or_flunk(value_to_check)

  
  @doc """
  Returns the content element of what must be a single-element Enum.

  '''
  [1]     |> singleton_content   # 1
  [ ]     |> singleton_content   # fails
  %{a: 1} |> singleton_content   # the tuple {:a, 1}
  """
  def singleton_content(value_to_check),
    do: singleton_or_flunk(value_to_check)

  # ----------------------------------------------------------------------------
  defp singleton_or_flunk(value_to_check) do 
    case Enum.into(value_to_check, []) do
      [x] -> x
      _ -> flunk """
           Expected a single element:
           #{inspect value_to_check}
           """
    end
  end
end  
