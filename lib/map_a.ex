defmodule FlowAssertions.MapA do
  use FlowAssertions.Define
  alias FlowAssertions.Messages
  alias FlowAssertions.{MiscA,EnumA}

  @moduledoc """
  Assertions that apply to Maps and structures and sometimes to keyword lists.

  `assert_fields/2` and `assert_same_map/3` are the most important.
  """

  @doc """
  Test the existence and value of multiple fields with a single assertion:

      assert_fields(some_map, key1: 12, key2: "hello")

  You can test just for existence:

      assert_fields(some_map, [:key1, :key2]

  The keyword list need not contain all of the fields in `some_map`.

  Values in the keyword list are compared as with
  `FlowAssertions.MiscA.assert_good_enough/2`. For example, regular
  expressions can be used to check strings:

      assert_fields(some_map, name: ~r/_cohort/)

  `assert_fields` can also take a map as its second argument. That's
  useful when the map to be tested has non-keyword arguments:

      assert_fields(string_map, %{"a" => 3})
  """

  # Credit: Steve Freeman inspired this.
  defchain assert_fields(kvs, list_or_map) do
    assert_present = fn key ->
      struct_must_have_key!(kvs, key)
      elaborate_assert(Map.has_key?(kvs, key),
        "Field `#{inspect key}` is missing",
        left: kvs,
        right: list_or_map)
      key
    end

    refute_single_error = fn key, expected ->
      adjust_assertion_error(fn ->
        MiscA.assert_good_enough(Map.get(kvs, key), expected)
      end, 
        message: Messages.wrong_field_value(key),
        expr: AssertionError.no_value)
    end
    
    list_or_map
    |> Enum.map(fn
      {key, expected} ->
        key |> assert_present.() |> refute_single_error.(expected)
      key ->
        assert_present.(key)
    end)
  end


  @doc """
  Same as `assert_fields/2` but more pleasingly grammatical
  when testing only one field:

      assert_field(some_map, key: "value")

  When checking existence, you don't have to use a list:

      assert_field(some_map, :key)
  """
  defchain assert_field(kvs, list) when is_list(list) do
    assert_fields(kvs, list)
  end

  defchain assert_field(kvs, singleton) do
    assert_fields(kvs, [singleton])
  end

  # ----------------------------------------------------------------------------

  @doc """
  Fail if any of the fields in the `field_list` are present.

      %{a: 1} |> refute_fields([:a, :b])    # fails
  """
  defchain refute_fields(some_map, field_list) when is_list(field_list) do
    for field <- field_list do
      elaborate_refute(Map.has_key?(some_map, field),
        Messages.field_wrongly_present(field),
        left: some_map)
    end
  end

  def refute_fields(some_map, field),
    do: refute_fields(some_map, [field])

  @doc """
  Same as refute_fields/2, but for a single field.

      %{a: 1} |> refute_field(:a)    # fails
  """
  def refute_field(some_map, field) when is_list(field),
    do: refute_fields(some_map, field)
  
  def refute_field(some_map, field), 
    do: refute_fields(some_map, [field])
    

  # ----------------------------------------------------------------------------
  @doc """
    An equality comparison of two maps that gives control over
    which fields should not be compared or should be compared differently.

    It is typically used after some `old` map has been transformed to make a
    `new` one. 

    To exclude some fields from the comparison:

        assert_same_map(new, old, ignoring: [:lock_version, :updated_at])

    To compare only some of the keys:

        assert_same_map(new, old, comparing: [:name, :people])

    To assert different values for particular fields:

        assert_same_map(new, old,
          except: [lock_version: old.lock_version + 1,
                   people: &Enum.empty/1])

    Note that the `except` comparison uses
    `FlowAssertions.MiscA.assert_good_enough/2`.


    Note that if the first value is a struct, the second must have the same type:

        Assertion with == failed
        left:  %S{b: 3}
        right: %R{b: 3}
  """
  defchain assert_same_map(new, old, opts \\ []) do
    if Keyword.has_key?(opts, :ignoring) && Keyword.has_key?(opts, :comparing),
      do: flunk("Test error: you can't use both `:ignoring` and `comparing")

    get_list = fn key -> Keyword.get(opts, key, []) end

    {remaining_new, remaining_old} = 
      compare_specific_fields(new, old, get_list.(:except))

    

    if Keyword.has_key?(opts, :comparing) do
      assert_comparing_keys(remaining_new, remaining_old, get_list.(:comparing))
    else
      assert_ignoring_keys(remaining_new, remaining_old, get_list.(:ignoring))
    end
  end

  # So much for the single responsibility principle. But it feels *so good*.
  defp compare_specific_fields(new, old, expected_kvs) do
    expected_keys = Keyword.keys(expected_kvs)
    struct_must_have_keys!(new, expected_keys)
    assert_fields(new, expected_kvs)

    { Map.drop(new, expected_keys), Map.drop(old, expected_keys)}
  end

  defp assert_ignoring_keys(new, old, fields_to_ignore) do
    struct_must_have_keys!(new, fields_to_ignore)
    elaborate_assert_equal(
      Map.drop(new, fields_to_ignore),
      Map.drop(old, fields_to_ignore))
  end

  defp assert_comparing_keys(new, old, fields_to_compare) do
    struct_must_have_keys!(new, fields_to_compare)
    elaborate_assert_equal(
      Map.take(new, fields_to_compare),
      Map.take(old, fields_to_compare))
  end

  # ----------------------------------------------------------------------------


  @doc """
  Assert that the value of the map at the key matches a binding form. 

      assert_field_shape(map, :field, %User{})
      assert_field_shape(map, :field, [_ | _])

  See `FlowAssertions.MiscA.assert_shape/2` for more.
  """
  defmacro assert_field_shape(map, key, shape) do
    quote do
      eval_once = unquote(map)
      adjust_assertion_error(fn -> 
        assert_shape(Map.fetch!(eval_once, unquote(key)), unquote(shape))
      end,
        message: Messages.no_field_match(unquote(key)))
      
      eval_once
    end
  end


  @doc """
  Take a map and a field. Return the single element in the field's value.

      with_singleton_content(%{a: [1]}, :a)   # returns `1`

  This is typically used with fields that take list values. Often,
  you only want to test the empty list and a singleton list.
  (When testing functions that produce their values with `Enum.map/2` or `for`,
  creating a second list element gains you nothing.)
  Using `with_singleton_content`, it's
  convenient to apply assertions to the single element:

      view_model
      |> assert_assoc_loaded(:service_gaps)
      |> with_singleton_content(:service_gaps)
         |> assert_shape(%VM.ServiceGap{})
         |> Ex.Datespan.assert_datestrings(:first)

  If `field` does not exist or isn't an `Enum`, `with_singleton_content` will fail in
  the same way `FlowAssertions.EnumA.singleton_content/1` does.
  """
  def with_singleton_content(map, field) do
    adjust_assertion_error(fn -> 
      map
      |> Map.get(field)
      |> EnumA.singleton_content
    end, message: Messages.expected_1_element_field(field))
  end
end
