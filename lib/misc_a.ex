defmodule FlowAssertions.MiscA do
  import FlowAssertions.Defchain
  import ExUnit.Assertions
  alias FlowAssertions.Messages

  @doc """
  Check if a value is an `:ok` or an `:ok` tuple.

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
  Check if value is an `:error` or an `:error` tuple.

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
  Fail unless the value given is a three-element tuple with the first
  element `:error` and the second a required subcategory of error.

  ```
  value_to_check |> assert_error(:error, :constraint)
  ```

  Note that the third element of the tuple is ignored.

  See also `error2_content/2`, which takes such a tuple and returns the
  third element.
  """

  # Hmm. Can't use `{:error, actual_subtype, content} = all` in the following.
  # Problem with defchain?
  defchain assert_error2({:error, actual_subtype, content}, expected_subtype) do
    if actual_subtype != expected_subtype do 
      elaborate_flunk(
        Messages.bad_error_3tuple_subtype(actual_subtype, expected_subtype),
        left: {:error, actual_subtype, content},
        right: expected_subtype)
    end
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
  def good_enough?(value_to_check, predicate) when is_function(predicate) do
    if is_function(value_to_check) do
      value_to_check == predicate
    else
      !! predicate.(value_to_check)
    end
  end

  def good_enough?(%Regex{} = value_to_check, %Regex{} = needed),
    do: value_to_check.source == needed.source

  def good_enough?(value_to_check, %Regex{} = needed) when is_binary(value_to_check),
    do: value_to_check =~ needed

  def good_enough?(value_to_check, needed),
    do: value_to_check == needed


  defchain assert_good_enough(value_to_check, predicate)
  when is_function(predicate) do
    if is_function(value_to_check) do
      assert value_to_check == predicate
    else
      assert_predicate predicate, value_to_check
    end
  end

  defchain assert_good_enough(value_to_check, needed) do
    if not good_enough?(value_to_check, needed) do
      assert value_to_check == needed
    end
  end

  defp assert_predicate(predicate, value_to_check) do
    predicate_value = predicate.(value_to_check)
    if not predicate_value do
      elaborate_flunk "Predicate #{inspect predicate} failed",
        left: value_to_check, right: predicate_value
    end
  end

  defp elaborate_flunk(message, opts) do
    try do
      flunk message
    rescue
      ex in ExUnit.AssertionError ->
        annotated =
          Enum.reduce(opts, ex, fn {k, v}, acc -> Map.put(acc, k, v) end)
        reraise annotated, __STACKTRACE__
    end
  end

  
  # ----------------------------------------------------------------------------
  @doc """
  Assert that the value the matches a binding form. 

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

  # def ok_id(x) do
  #   ok_content(x).id
  # end


  # # Note that these return the extracted value_to_check, not the first argument.

  # def with_singleton(%Changeset{} = changeset, fetch_how, field) do
  #   apply(ChangesetX, fetch_how, [changeset, field])
  #   |> singleton_content
  # end

  # def sorted_by_id(container, field) do
  #   container
  #   |> Map.get(field)
  #   |> EnumX.sort_by_id
  # end
end
