defmodule FlowAssertions.Define.BodyParts do
  import ExUnit.Assertions
  alias ExUnit.AssertionError
  import FlowAssertions.Define.Defchain
  alias FlowAssertions.Messages
  
  @moduledoc """
  Functions helpful in the construction of a new assertion.

  Mostly, they give you more control over what's shown in a failing test by letting
  you set `ExUnit.AssertionError` values like `:left` and `:right`.

  All such functions take a string first argument. That's shorthand
  for setting the `:message` field.
  """
  
  @doc """
  Like `ExUnit.Assertions.flunk/1` but the second argument is used to set `AssertionError` keys. 

  ```
  elaborate_flunk("the value is wrong", left: value_to_check)
  ```

  Warning: as far as I know, the structure of `ExUnit.AssertionError` is not
  guaranteed to be stable.

  See also `elaborate_assert/3`.
  """

  def elaborate_flunk(message, opts) do
    try do
      flunk message
    rescue
      ex in AssertionError ->
        annotated =
          Enum.reduce(opts, ex, fn {k, v}, acc -> Map.put(acc, k, v) end)
        reraise annotated, __STACKTRACE__
    end
  end

  
  @doc """
  Like `ExUnit.Assertions.assert/2` but the third argument is used to set `AssertionError` keys. 

  ```
    elaborate_assert(
      left =~ right,
      "Regular expression didn't match",
      left: left, right: right)

  ```

  Warning: as far as I know, the structure of `ExUnit.AssertionError` is not
  guaranteed to be stable.

  See also `elaborate_assert_equal/4`.

  """

  defchain elaborate_assert(value, message, opts) do
    if !value, do: elaborate_flunk(message, opts)
  end

  @doc """
  This replicates the diagnostic output from `assert a == b`, except for the
  code snippet that's reported.

  The user will see a failing test containing:

      Assertion with == failed
      code:  assert_same_map(new, old, ignoring: [:stable])
      left:  ...
      right: ...


  ... instead of the assertion that actually failed, something like this:

      Assertion with == failed
      code:  assert Map.drop(new, fields_to_ignore) == Map.drop(old, fields_to_ignore)
      left:  ...
      right: ...
  """
  defchain elaborate_assert_equal(left, right) do
    elaborate_assert(left == right,
      Messages.stock_equality,
      left: left, right: right,
      expr: AssertionError.no_value)
  end

  # ----------------------------------------------------------------------------
  @doc """
  Flunk test if it checks structure fields that don't exist.

  It doesn't make sense to write an assertion that checks a field that
  a structure can't contain. If a user tries, this function will object with a message like: 
  
  ```
  Test error: there is no key `:b` in a `MyApp.Struct`
  ```

  Notes:

  * It's safe to call on non-struct values.
  * It returns its first argument.

  """
  
  defchain struct_must_have_key!(struct, key) when is_struct(struct),
    do: assert Map.has_key?(struct, key), Messages.required_key_missing(key, struct)
  def struct_must_have_key!(x, _), do: x

  @doc"""
  Same as `struct_must_have_key!/2` but checks multiple keys.
  """
  defchain struct_must_have_keys!(struct, keys) when is_struct(struct) do 
    for key <- keys, do: struct_must_have_key!(struct, key)
  end
  def struct_must_have_keys!(x, _), do: x

  # ----------------------------------------------------------------------------

  @doc ~S"""
  Run a function, perhaps generating an assertion error. If so, use the
  keyword arguments to replace values in the error. 

      adjust_assertion_error(fn ->
        MiscA.assert_good_enough(Map.get(kvs, key), expected)
      end, 
        message: "Field `#{inspect key}` has the wrong value",
        expr: AssertionError.no_value)

  Setting the `expr` field to `AssertionError.no_value` has the handy effect of
  making the reporting machinery report the code of the assertion the user called,
  rather than the assertion that generated the error.
  """
  def adjust_assertion_error(f, replacements) do
    try do
      f.()
    rescue
      ex in AssertionError ->
        Enum.reduce(replacements, ex, fn {key, value}, acc ->
          Map.put(acc, key, value)
        end)
        |> reraise(__STACKTRACE__)
    end
  end
end  
