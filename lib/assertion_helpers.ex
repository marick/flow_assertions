defmodule FlowAssertions.AssertionHelpers do
  import ExUnit.Assertions
  import FlowAssertions.Defchain
  
  @moduledoc """
  Functions that allow a little more control over what people see when
  tests fail.
  """

  
  @doc """
  A variant of `ExUnit.Assertions.flunk/1` that gives more control over
  what's shown in a failing test by letting you set `ExUnit.AssertionError`
  values like `:left` and `:right`.

  ```
  elaborate_flunk("the value is wrong", left: value_to_check)
  ```

  Warning: as far as I know, the structure of `AssertionError` is not
  guaranteed to be stable.

  See also `elaborate_assert/3`.

  """

  def elaborate_flunk(message, opts) do
    try do
      flunk message
    rescue
      ex in ExUnit.AssertionError ->
        annotated =
          Enum.reduce(opts, ex, fn {k, v}, acc -> Map.put(acc, k, v) end)
        reraise annotated, __STACKTRACE__
    end
  end

  
  @doc """
  A variant of `ExUnit.Assertions.assert/2` that gives more control over
  what's shown in a failing test by letting you set `ExUnit.AssertionError`
  values like `:left` and `:right`.

  ```
    elaborate_assert(
      left =~ right,
      "Regular expression didn't match",
      left: left, right: right)

  ```

  Warning: as far as I know, the structure of `AssertionError` is not
  guaranteed to be stable.

  See also `elaborate_assert/3`.

  """

  defchain elaborate_assert(value, message, opts) do
    if !value, do: elaborate_flunk(message, opts)
  end


  def adjust_assertion_error(f, replacements) do
    try do
      f.()
    rescue
      ex in ExUnit.AssertionError ->
        Enum.reduce(replacements, ex, fn {key, value}, acc ->
          Map.put(acc, key, value)
        end)
        |> reraise(__STACKTRACE__)
    end
  end
end  
