defmodule FlowAssertions.Messages do

  @moduledoc false

  def not_ok, do: "Value is not `:ok` or an `:ok` tuple"
  def not_ok_tuple, do: "Value is not an `:ok` tuple"
  def not_error, do: "Value is not an `:error` or `:error` tuple"
  def not_error_tuple, do: "Value is not an `:error` tuple"
  def not_error_3tuple(error_subtype),
    do: "Value is not of the form `{:error, #{inspect error_subtype}, <content>}`"
  def bad_error_3tuple_subtype(actual, expected),
    do: "The error subtype is `#{inspect actual}`, not the expected `#{inspect expected}`"
  def failed_predicate(predicate), do: "Predicate #{inspect predicate} failed"
  def no_regex_match, do: "Regular expression didn't match"

  # Note that the lack of `inspect` is deliberate.
  def failed_checker(name), do: "Checker `#{name}` failed"
  

  def stock_equality, do: "Assertion with == failed"

  def no_match, do: "The value doesn't match the given pattern"
  def no_field_match(field),
    do: "The value for field `#{inspect field}` doesn't match the given pattern"

  def not_no_value(key, no_value), 
    do: "Expected key `#{inspect key}` to be `#{inspect no_value}`."

  def not_value(key), 
    do: "Expected key `#{inspect key}` to have a value."

  def expected_1_element, do: "Expected a single element"
  def expected_no_element, do: "Expected an empty Enum"
  def expected_1_element_field(key),
    do: "Expected field `#{inspect key}` to be a single element Enum"



  def required_key_missing(key, struct) do 
    struct_name = struct.__struct__
    "Test error: there is no key `#{inspect key}` in a `#{inspect struct_name}`"
  end

  def wrong_struct_name(actual_name, expected_name),
    do: "Expected a `#{inspect expected_name}` but got a `#{inspect actual_name}`"

  def map_not_struct(expected_name),
    do: "Expected a `#{inspect expected_name}` but got a plain Map"

  def very_wrong_struct(expected_name),
    do: "Expected a `#{inspect expected_name}`"

  def wrong_field_value(key), do: "Field `#{inspect key}` has the wrong value"
  def field_missing(field), do: "Field `#{inspect field}` is missing"

  def not_enumerable, do: "Expected an `Enumerable`"

  def different_length_collections, do: "The two collections have different lengths"
  def different_elements_collections, do: "The two collections have different elements"
  
end
