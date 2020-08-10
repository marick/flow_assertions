defmodule FlowAssertions.MiscA do
  import FlowAssertions.{Defchain,AssertionHelpers}
  import ExUnit.Assertions
  alias FlowAssertions.Messages

  @doc """
  Check if a value is an `:ok` or an `{:ok, <content>}` tuple.

  ```
  value_to_check |> assert_ok(:ok)
  value_to_check |> assert_ok({:ok, "any value is accepted"})
  ```

  See also `ok_content/1`, which takes an `:ok` tuple and returns the
  second element.
  """
  
  def assert_ok(:ok), do: :ok
  def assert_ok({:ok, _} = value_to_check), do: value_to_check
  def assert_ok(value_to_check),
    do: elaborate_flunk(Messages.not_ok, left: value_to_check)

  @doc """
  Fails with an `AssertionError` unless the argument is of the form
  `{:ok, content}`. Returns the `content` value.

  `ok_content` is used to
  let the rest of an assertion chain operate on the `content`:

  ```
  |> ReservationApi.create(ready, @institution)
  |> ok_content
  |> assert_field(count: 5)
  ```
  See also `assert_ok/1`.
  """
  def ok_content({:ok, content}), do: content
  def ok_content(actual),
    do: elaborate_flunk(Messages.not_ok_tuple, left: actual)


  @doc """
  Extract the `:id` field from an {:ok, %{id: id, ...}} value.

  Shorthand for `ok_content(x).id`. 
  """
  def ok_id(x), do: ok_content(x).id

  @doc """
  Check if value is an `:error` or an `{:error, <content>}` tuple.

  ```
  value_to_check |> assert_error(:error)
  value_to_check |> assert_error({:error, "any value is accepted"})
  ```

  See also `error_content/1`, which takes an `:error` tuple and returns the
  second element.
  """
  def assert_error(:error), do: :error
  def assert_error({:error, _} = value_to_check), do: value_to_check
  # failure with nice error
  def assert_error(value_to_check), 
    do: elaborate_flunk(Messages.not_error, left: value_to_check)

  @doc """
  Fails with an `AssertionError` unless the argument is of the form
  `{:error, content}`. Returns the `content` value.

  `error_content` is used to
  let the rest of an assertion chain operate on the `content`:

  ```
  |> ReservationApi.create(ready, @institution)
  |> error_content
  |> assert_equals("some error message")
  ```
  See also `assert_error/1`.
  """
  def error_content({:error, content}), do: content
  def error_content(left),
    do: elaborate_flunk(Messages.not_error_tuple, left: left)


  @doc """
  A variant of `assert_error/2` for three-element `:error` tuples.

  ```
  value_to_check |> assert_error(:error, :constraint)
  ```

  Sometimes it's useful for an `:error` tuple to identify different
  kinds of errors. For example, Phoenix form processing errors might
  be due to either `:validation` or `:constraint` errors and reported
  in a tuple like `{:error, :constraint, <message>}`

  This function checks that the second element is as required. The
  third element is ignored.

  See also `error2_content/2`, which takes such a tuple and returns the
  third element.
  """

  # Hmm. Can't use `{:error, actual_subtype, content} = all` in the following.
  # Problem with defchain?
  defchain assert_error2({:error, actual_subtype, content}, expected_subtype) do
    elaborate_assert(
      actual_subtype == expected_subtype,
      Messages.bad_error_3tuple_subtype(actual_subtype, expected_subtype),
      left: {:error, actual_subtype, content},
      right: expected_subtype)
  end
  
  def assert_error2(value_to_check, expected_error_subtype) do
    elaborate_flunk(Messages.not_error_3tuple(expected_error_subtype),
      left: value_to_check)
  end

  @doc """
  Fail unless the value given is a three-element tuple with the first
  element `:error` and the second a
  required subcategory of error. Returns the third element. 

  `error_content` is used to
  let the rest of an assertion chain operate on the `content`:

  ```
  |> ReservationApi.create(ready, @institution)
  |> error2_content(:constraint)
  |> assert_equals("some error message")
  ```
  See also `assert_error2/2`.
  """
  def error2_content(value_to_check, second) do
    assert_error2(value_to_check, second) |> elem(2)
  end

  # ----------------------------------------------------------------------------
  @doc """
  The chaining version of `assert x === y`.

  This is useful for cases where you're adding onto a pipeline of
  assertions or content-extraction checks (like `ok_content/1`).

  ```
  value_to_check |> ok_content |> assert_equal(3)
  ```

  Note that the comparison is done with `===`, so `1` is not equal to
  `1.0`. 
  """
  defchain assert_equal(x, y), do: assert x === y

  @doc """
  Synonym for `assert_equal`.
  """
  defchain assert_equals(x, y), do: assert x === y

  
  @doc """
  Think of it as a form of equality with special handling for functions
  and regular expressions.

  ```
  good_enough?(1, &odd/1)             # true
  good_enough?("string", ~r/s.r..g/)  # true
  ```

  If the second argument is a regular expression and the first is a string, the two
  are compared with `=~`. 

  If *both* arguments are regular expressions, their `source` fields are compared.

  If the second argument is a function and the first is not, the function
  is applied to the first argument. `good_enough?` returns true iff the
  result is truthy. 

  Otherwise, the two are compared with `==`. 

  See also `assert_good_enough/2`
  """
  def good_enough?(actual, expected) do 
    try do
      assert_good_enough(actual, expected)
      true
    rescue
      ExUnit.AssertionError -> false
    end
  end



  @doc """
  Like `assert x == y`, but with special handling for predicates and
  regular expressions.

  By default `assert_good_enough` uses `==` to test the left side
  against the right. However:

  * If the right side is a regular expression and the left side
    is not, the two are compared with `=~` rather than `==`.

  * If the right side is a function and the left side is not,
    the function is applied to the value. Any "falsy" value
    is a failure.

  ```
  assert_good_enough?(1, &odd/1)
  assert_good_enough?("string", ~r/s.r..g/)
  ```
  See also `good_enough?/2`
  """
  defchain assert_good_enough(value_to_check, predicate)
  when is_function(predicate) and not is_function(value_to_check) do
    elaborate_assert(
      predicate.(value_to_check),
      Messages.failed_predicate(predicate),
      left: value_to_check)
  end

  defchain assert_good_enough(%Regex{} = left, %Regex{} = right) do
    elaborate_assert(
      left.source == right.source,
      Messages.stock_equality, left: left, right: right)
  end

  defchain assert_good_enough(left, %Regex{} = right) when is_binary(left) do
    elaborate_assert(
      left =~ right,
      Messages.no_regex_match, left: left, right: right)
  end

  defchain assert_good_enough(value_to_check, needed) do
    assert value_to_check == needed
  end
  
  # ----------------------------------------------------------------------------
  @doc """
  Assert that the value matches a binding form. 

  ```
  value_to_check |> assert_shape(%User{})
  value_to_check |> assert_shape(thing, [_ | _])
  ```

  Note that this is a macro that uses the match operator, so all of Elixir's
  pattern matching is available. For example, you can use a map to partially
  match a structure:

  ```
  make_user("fred") |> assert_shape(%{name: "fred"})
  ```

  Or you can pin a value: 

  ```
  make_user("fred") |> assert_shape(%{name: ^chosen_name})
  ```

  See also `FlowAssertions.StructA.assert_struct_named/2`. 
  """

  # Can't use this:
  #   if not match?(unquote(shape), eval_once) do
  #     elaborate_flunk("The value doesn't match the given pattern.",
  #       left: eval_once, right: unquote(shape))
  #
  # ... because the shape might have a pinned value. 

  
  defmacro assert_shape(value_to_check, shape) do 
    pattern_string = Macro.to_string(shape)
    quote do 
      eval_once = unquote(value_to_check)
      assert(match?(unquote(shape), eval_once),
        """
        The value doesn't match the given pattern.
        value:   #{inspect eval_once}
        pattern: #{unquote(pattern_string)}
        """)
      eval_once
    end
  end
end
