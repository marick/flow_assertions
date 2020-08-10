defmodule FlowAssertions.EnumA do
  use FlowAssertions.Define

  @moduledoc """
  Assertions that apply to Enums.
  """

  @doc """
  Assert that an Enum has only a single element.
  ```
  [1] |> assert_singleton   # passes
  [ ] |> assert_singleton   # fails

  %{a: 1} |> assert_singleton       # passes
  %{a: 1, b: 2} |> assert_singleton # fails
  ```
  """

  defchain assert_singleton(enum),
    do: singleton_or_flunk(enum)

  
  @doc """
  Returns the content element of what must be a single-element Enum.

  '''
  [1]     |> singleton_content   # 1
  [ ]     |> singleton_content   # fails
  %{a: 1} |> singleton_content   # the tuple {:a, 1}
  """
  def singleton_content(enum),
    do: singleton_or_flunk(enum)

  @doc """
  Assert that an Enum has no elements."
  ```
  [] |> assert_empty    # true
  %{} |> assert_empty   # true
  ```
  """
  defchain assert_empty(value_to_check) do
    if not Enum.empty?(value_to_check),
      do: flunk("Expected an empty Enum")
  end

  
  
  # ----------------------------------------------------------------------------
  defp singleton_or_flunk(enum) do 
    case Enum.into(enum, []) do
      [x] -> x
      _ -> flunk """
           Expected a single element:
           #{inspect enum}
           """
    end
  end
end  
