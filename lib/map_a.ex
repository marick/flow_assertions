defmodule FlowAssertions.MapA do
  use FlowAssertions.Define
  alias FlowAssertions.MiscA

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
      assert_no_struct_key_typos(kvs, key)
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
        message: "Field `#{inspect key}` has the wrong value",
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
  Same as `assert_fields` but more pleasingly grammatical
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
    assert_no_struct_key_typos(new, expected_keys)
    assert_fields(new, expected_kvs)
    { Map.drop(new, expected_keys), Map.drop(old, expected_keys)}
  end

  defp assert_ignoring_keys(new, old, fields_to_ignore) do
    assert_no_struct_key_typos(new, fields_to_ignore)
    elaborate_assert_equal(
      Map.drop(new, fields_to_ignore),
      Map.drop(old, fields_to_ignore))
  end

  defp assert_comparing_keys(new, old, fields_to_compare) do
    assert_no_struct_key_typos(new, fields_to_compare)
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

  # ------------------------------------------------------------------------

  defp assert_no_struct_key_typos(map, keys) when is_list(keys) do
    for key <- keys, 
      do: assert_no_struct_key_typos(map, key)
  end
      
  
  defp assert_no_struct_key_typos(map, key) do
    if Map.has_key?(map, :__struct__) do
      assert Map.has_key?(map, key),
        "Test error: there is no key `#{inspect key}` in #{inspect map.__struct__}"
    end
  end
  
end
