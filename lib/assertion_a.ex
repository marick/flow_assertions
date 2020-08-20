defmodule FlowAssertions.AssertionA do
  
  @moduledoc """
  Assertions used to test other assertions.

  These assertions do not work on the textual output of an assertion
  error. Instead, they inspect the internals of the
  `ExUnit.AssertionError` structure. Here is an example:

  ```elixir
    assertion_fails(
      "some text"
      [left: "something"],
      fn -> 
        assert_no_value(data, :something_field)
      end)
  ```

  The first argument ("some text") describes the expected `:message` field.
  The next line describes the value expected in the `:left` field. 

  As far as I know, the `ExUnit.AssertionError` isn't guaranteed to
  stay stable, so beware.  As of August 2020, these are the fields
  you can use:
  
      defexception left: @no_value,
                   right: @no_value,
                   message: @no_value,
                   expr: @no_value,
                   args: @no_value,
                   doctest: @no_value,
                   context: :expr

  """
  
  import ExUnit.Assertions
  alias ExUnit.AssertionError
  import FlowAssertions.Define.Defchain
  alias FlowAssertions.MapA

  @doc """
  Check if an assertion fails in the expected way.

  The assertion must be wrapped in a function:

  ```elixir
      fn -> 
        assert_no_value(data, :something_field)
      end)
  ```

  A typical call looks like this:

  ```elixir
     assertion_fails(
        "some text"
        [left: "something"],
        fn -> ... end)
  ```

  The first argument is the expected `:message` field in the
  `ExUnit.AssertionError` structure.

  The second argument is a keyword list describing the other fields of
  the `AssertionError` structure.

  The `:message` value and the other field values will be compared using 
  `FlowAssertions.MiscA.good_enough?/2`. So, for example, the check of the
  error message need not be exact:

  ```elixir
     assertion_fails(
        ~r/some text.*final text/,
        ...
  ```

  If the assertion correctly fails, the return value is the
  `ExUnit.AssertionError` the assertion created.
  """
  def assertion_fails(message, kws \\ [], f) do
    assert_raise(AssertionError, f)
    |> MapA.assert_fields(kws ++ [message: message])
  end

  @doc """
  A variant of `assertion_fails/3` that is useful in chaining.


  This assertion is tailored for a function that is passed through a pipeline
  and exposed to different arguments at each stage:

  ```elixir
    msg = "..."

    (&error_content/1)                    # <= parentheses are important
    |> assertion_fails_for(:error, msg)
    |> assertion_fails_for({:ok, "content"}, msg)
  ```

  In the above case, `FlowAssertions.MiscA.error_content/1` is exposed to
  two different values. Both should cause an `ExUnit.AssertionError` with a
  particular `:message`.

  A third argument could describe other `ExUnit.AssertionError`
  fields, as in `assertion_fails/3`.

  Note the parentheses around `error_content/1`. They are required by
  Elixir's precedence rules: `&` binds more loosely than `|>`. If you
  leave the parentheses off, the expression turns into a single
  function that's never executed - meaning that the test can never
  fail, no matter how broken the code is.
  """
  defchain assertion_fails_for(under_test, left, message, kws \\ []) do
    assert_raise(AssertionError, fn -> under_test.(left) end)
    |> MapA.assert_fields(kws ++ [message: message, left: left])
  end
end
