defmodule FlowAssertions.Messages do 

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

  def stock_equality, do: "Assertion with == failed"
end
