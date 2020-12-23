defmodule FlowAssertions.Checkers do
  alias FlowAssertions.Define.Defchecker.Failure
  import FlowAssertions.Define.Defchecker
  alias FlowAssertions.Messages

  @moduledoc """
  Functions that create handy predicates for use with `FlowAssertions.MiscA.assert_good_enough/2`

      actual
      |> assert_good_enough( in_any_order([1, 2, 3]))

  "Checkers" typically provide custom failure messages that are better than
  what a simple predicate would provide.

  This module is a work in progress, but what now works will continue to work
  and can be used safely. For examples of what checkers might come, see the
  [Midje documentation](https://github.com/marick/Midje/wiki). (Links are under
  the third bullet point of "The Core" on that page.)
  
  """

  @doc """
  Check equality of Enumerables, ignoring order.

      actual
      |> assert_good_enough( in_any_order([1, 2, 3]))

  In case of error, the actual and expected enumerables are sorted by
  by their `Kernel.inspect/1` representation. In combination with ExUnit's
  color-coded differences, that makes it easier to see what went wrong.
  
  """

  def in_any_order(expected) do
    fn actual ->
      assert = fn value, message ->
        if !value do
          Failure.boa(actual, :in_any_order, expected)
          |> fail_helpfully(message, alphabetical_enums(actual, expected))
        end
      end

      id = fn x -> x end
      unordered = &(Enum.group_by(&1, id))

      assert.(length(actual) == length(expected),
        Messages.different_length_collections)

      assert.(unordered.(actual) == unordered.(expected),
        Messages.different_elements_collections)
      true
    end
  end

  defp alphabetical_enums(actual, expected),
    do: [left: alphabetical(actual), right: alphabetical(expected)]
  defp alphabetical(xs), do: Enum.sort_by(xs, &to_string/1)

    

  @doc """
  TBD
  """
  def has_slice(expected) when is_binary(expected) do
    fn actual when is_binary(actual) ->
      if String.contains?(actual, expected),
        do: true,
        else: Failure.boa(actual, :has_slice, expected)
    end
  end

  def has_slice(expected) when is_list(expected) do
    fn actual when is_list(actual) ->
      if has_prefix?(actual, expected),
        do: true,
        else: Failure.boa(actual, :has_slice, expected)
    end
  end

  defp has_prefix?([], []), do: true
  defp has_prefix?([], _), do: false
  defp has_prefix?([_ | rest] = larger, prefix) when is_list(prefix) do
    comparison_length = length(prefix)
    cond do
      length(larger) < comparison_length ->
        false
      Enum.take(larger, comparison_length) == prefix ->
        true
      true ->
        has_prefix?(rest, prefix)
    end
  end
end  
