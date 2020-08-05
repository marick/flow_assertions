defmodule FlowAssertions.MapA do
  # import FlowAssertions.Defchain
  # import ExUnit.Assertions
  # import FlowAssertions.Misc

  # @doc """
  # Test the existence and value of multiple fields with a single assertion:

  #     assert_fields(some_map, key1: 12, key2: "hello")

  # Alternately, you can test just for existence:

  #     assert_fields(some_map, [:key1, :key2]

  # The second argument needn't contain all of the fields in the value under
  # test. 

  # In case of success, the first argument is returned so that making multiple
  # assertions about the same value can be done without verbosity:

  #     some_map
  #     |> assert_fields([:key1, :key2])
  #     |> assert_something_else
    
  # """

  # # Credit: Steve Freeman inspired this.
  # defchain assert_fields(kvs, list) do
  #   assert_present = fn key -> 
  #     assert_no_typo_in_struct_key(kvs, key)
  #     assert Map.has_key?(kvs, key), "Field `#{inspect key}` is missing"
  #   end
    
  #   list
  #   |> Enum.map(fn
  #     {key, expected} ->
  #       assert_present.(key)
  #       assert_extended_equality(Map.get(kvs, key), expected, key)
  #     key ->
  #       assert_present.(key)
  #   end)
  # end

  # @doc """
  # Same as `assert_fields` but more pleasingly grammatical
  # when testing only one field:

  #     assert_field(some_map, key: "value")

  # When checking existence, you don't have to use a list:

  #     assert_field(some_map, :key)
  # """
  # defchain assert_field(kvs, list) when is_list(list) do
  #   assert_fields(kvs, list)
  # end

  # defchain assert_field(kvs, singleton) do
  #   assert_fields(kvs, [singleton])
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

  

  # @doc """
  #   An equality comparison of two maps that gives control over
  #   which fields should not be compared, or should be compared differently.

  #   To exclude some fields from the comparison:

  #       assert_copy(new, old, ignoring: [:lock_version, :updated_at])

  #   To assert different values for particular fields (as in `assert_fields`):

  #       assert_copy(new, old,
  #         except: [lock_version: old.lock_version + 1,
  #                  people: &Enum.empty/1])

  #   Combine both for concise assertions:

  #     AnimalT.update_for_success(original_animal.id, params)
  #     |> assert_copy(original_animal,
  #          except:[
  #            in_service_datestring: dates.iso_next_in_service,
  #            span: Datespan.inclusive_up(dates.next_in_service),
  #            lock_version: 2]
  #          ignoring: [:updated_at])
  # """
  # defchain assert_copy(new, old, opts \\ []) do
  #   except = Keyword.get(opts, :except, [])
  #   ignoring_keys =
  #     Keyword.get(opts, :ignoring, []) ++ Keyword.keys(except)

  #   Enum.map(ignoring_keys, &(assert_no_typo_in_struct_key(new, &1)))
      
  #   assert_fields(new, except)
  #   assert Map.drop(new, ignoring_keys) == Map.drop(old, ignoring_keys)
  # end


  # defchain assert_partial_copy(new, old, fields_to_compare) do
  #   assert Map.take(new, fields_to_compare) == Map.take(old, fields_to_compare)
  # end

  # defp assert_extended_equality(actual, predicate, key) when is_function(predicate) do
  #   msg = "#{inspect key} => #{inspect actual} fails predicate #{inspect predicate}"
  #   assert(predicate.(actual), msg)
  # end

  # defp assert_extended_equality(actual, expected, key) do
  #   msg =
  #     """
  #     `#{inspect key}` has the wrong value.
  #     actual:   #{inspect actual}
  #     expected: #{inspect expected}
  #     """
  #   assert(actual == expected, msg)
  # end


  # @doc """
  # Complain if given a key that doesn't exist in the argument (if it's a struct).
  # """
  # defchain assert_no_typo_in_struct_key(map, key) do
  #   if Map.has_key?(map, :__struct__) do
  #     assert Map.has_key?(map, key),
  #       "Test error: there is no key `#{inspect key}` in #{inspect map.__struct__}"
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


  # # ------------------------------------------------------------------------

  
end
