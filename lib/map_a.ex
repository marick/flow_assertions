defmodule FlowAssertions.MapA do
  import ExUnit.Assertions
  import FlowAssertions.{Defchain,AssertionHelpers}
  alias FlowAssertions.MiscA
  alias ExUnit.AssertionError

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
      assert_no_typo_in_struct_key(kvs, key)
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

  @doc """
    An equality comparison of two maps that gives control over
    which fields should not be compared or should be compared differently.

    It is typically used after some `old` map has been transformed to make a
    `new` one.

    To exclude some fields from the comparison:

        assert_same_map(new, old, ignoring: [:lock_version, :updated_at])

    To assert different values for particular fields:

        assert_same_map(new, old,
          except: [lock_version: old.lock_version + 1,
                   people: &Enum.empty/1])

    Note that the `except` comparison uses
    `FlowAssertions.MiscA.assert_good_enough/2`.

    See also `assert_same_subset/3`
  """
  defchain assert_same_map(new, old, opts \\ []) do
    except = Keyword.get(opts, :except, [])
    ignoring_keys =
      Keyword.get(opts, :ignoring, []) ++ Keyword.keys(except)

    for key <- ignoring_keys, 
      do: assert_no_typo_in_struct_key(new, key)
      
    assert_fields(new, except)
    assert Map.drop(new, ignoring_keys) == Map.drop(old, ignoring_keys)
  end


  # defchain assert_same_subset(new, old, fields_to_compare) do
  #   assert Map.take(new, fields_to_compare) == Map.take(old, fields_to_compare)
  # end




  # @doc """
  # Assert that the value of the map at the key matches a binding form. 

  #     assert_field_shape(map, :field, %User{})
  #     assert_field_shape(map, :field, [_ | _])
  # """
  # defmacro assert_field_shape(map, key, shape) do
  #   quote do
  #     eval_once = unquote(map)
  #     assert_shape(Map.fetch!(eval_once, unquote(key)), unquote(shape))
  #     eval_once
  #   end
  # end


  

  # # ----------------------------------------------------------------------------
  # @doc """
  # `assert_nothing` assumes a convention of initializing keys in a map to
  # the sentinal value `:nothing`, with the expectation is that it will later
  # be given a real value. This is useful in multi-step construction of, for
  # example, CritWeb.Reservations.AfterTheFactStructs.

  # `assert_nothing` requres that, for each key, the map's value for that key be
  # `:nothing`.
  # """

  # defchain assert_nothing(map, keys) when is_list(keys) do
  #   Enum.map(keys, fn key ->
  #     refute(MapX.just?(map, key), "Expected key `#{inspect key}` to be `:nothing`")
  #   end)
  # end

  # def assert_nothing(map, key), do: assert_nothing(map, [key])

  # @doc """
  # `refute_nothing` assumes a convention of initializing keys in a map to
  # the sentinal value `:nothing`, with the expectation is that it will later
  # be given a real value. This is useful in multi-step construction of, for
  # example, CritWeb.Reservations.AfterTheFactStructs.

  # `refute_nothing` requres that, for each key, the map's value for that key *not*
  # be `:nothing`.
  # """
  
  # defchain refute_nothing(map, keys) when is_list(keys) do
  #   Enum.map(keys, fn key ->
  #     assert(MapX.just?(map, key),
  #       "Key `#{inspect key}` unexpectedly has value `:nothing`")
  #   end)
  # end

  # def refute_nothing(map, key), do: refute_nothing(map, [key])

  # ------------------------------------------------------------------------

  defp assert_no_typo_in_struct_key(map, key) do
    if Map.has_key?(map, :__struct__) do
      assert Map.has_key?(map, key),
        "Test error: there is no key `#{inspect key}` in #{inspect map.__struct__}"
    end
  end
  
end
