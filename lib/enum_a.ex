defmodule FlowAssertions.EnumA do
  use FlowAssertions.Define
  alias FlowAssertions.Messages
  alias FlowAssertions.StructA

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
  5       |> singleton_content   # faila
  """
  def singleton_content(enum),
    do: singleton_or_flunk(enum)


  
  @doc """
  Combines `singleton_content/1` and `FlowAssertions.StructA.assert_struct_named/2`. 

  ```
  |> VM.Animal.lift(Schema.Animal)
  |> singleton_content(VM.Animal)
  |> assert_fields(...)

  ```

  In addition to checking that the value is a singleton Enumerable, it
  checks that the `content` is a value of the named struct before returning it.
  """

  def singleton_content(enum, struct_name) do 
    singleton_content(enum)
    |> StructA.assert_struct_named(struct_name)
  end


  
  @doc """
  Assert that an Enum has no elements."
  ```
  [] |> assert_empty    # true
  %{} |> assert_empty   # true
  ```
  """
  defchain assert_empty(value_to_check) do
    assert_enumerable(value_to_check)
    elaborate_assert(Enum.empty?(value_to_check),
      Messages.expected_no_element,
      left: value_to_check)
  end

  @doc """
  If the value doesn't implement `Enumerable` produces an assertion exception.

  The output is more friendly than a `Protocol.UndefinedError`. So, for example,
  the other assertions in this module start with this assertion.

      defchain assert_empty(value_to_check) do
        assert_enumerable(value_to_check)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        elaborate_assert(Enum.empty?(value_to_check),
          Messages.expected_no_element,
          left: value_to_check)
      end
  """
  
  defchain assert_enumerable(value_to_check) do
    elaborate_assert(Enumerable.impl_for(value_to_check),
      Messages.not_enumerable, left: value_to_check)
  end
  
  # ----------------------------------------------------------------------------
  defp singleton_or_flunk(enum) do
    assert_enumerable(enum)
    case Enum.into(enum, []) do
      [x] -> x
      _ -> elaborate_flunk(Messages.expected_1_element, left: enum)
    end
  end
end  
