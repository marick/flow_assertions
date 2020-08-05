defmodule FlowAssertions.MiscA do
  import FlowAssertions.Defchain
  import ExUnit.Assertions

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
  # failure with nice error
  def assert_ok(value_to_check), do: assert value_to_check == :ok

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
  def ok_content(tuple) do
    assert {:ok, content} = tuple
    content
  end

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
  def assert_error(value_to_check), do:  assert value_to_check == :error 

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
  def error_content(tuple) do
    assert {:error, content} = tuple
    content
  end


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
  def assert_error2(value_to_check, second) do
    assert {:error, ^second, content} = value_to_check
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
    assert_error2(value_to_check, second)
    assert {:error, ^second, content} = value_to_check
    content
  end

  # ----------------------------------------------------------------------------
  @doc """
  The chaining version of `assert x == y`, for cases where you're adding
  onto a pipeline of assertions or content-extraction checks (like `ok_content/1`). 
  ```
  value_to_check |> ok_content |> assert_equal(3)
  ```
  """
  defchain assert_equal(x, y), do: assert x == y

  @doc """
  Synonym for `assert_equal`.
  """
  defchain assert_equals(x, y), do: assert x == y

  
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