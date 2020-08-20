defmodule FlowAssertions.Checkers do
  alias FlowAssertions.Define.Defchecker.Failure
  import FlowAssertions.Define.Defchecker
  import ExUnit.Assertions
  alias FlowAssertions.Messages

  @moduledoc """
  Functions that create handy predicates for use with `FlowAssertions.MiscA.assert_good_enough/2`
  """

  @doc """
  TBD
  """

  # def in_any_order(expected) do
  #   id = fn x -> x end
  #   fn actual ->
  #     cond do 
  #       length(expected) != length(actual) ->
  #         true
          
  #     else
  #       group_actual = Enum.group_by(actual, id)
  #       group_expected = Enum.group_by(expected, id)
  #       group_actual == group_expected
  #     end
  #   end
  # end
      
  
  
  def in_any_order(expected) do
    fn actual ->
      id = fn x -> x end
      group_actual = Enum.group_by(actual, id)
      group_expected = Enum.group_by(expected, id)

      cond do
        length(actual) != length(expected) ->
          failure =
            Failure.new(
              mfa: {__MODULE__, :in_any_order, [expected]},
              actual: actual)
          fail_helpfully(failure, Messages.different_length_collections,
            left: alphabetical(actual), right: alphabetical(expected))
        group_actual != group_expected ->
          failure =
            Failure.new(
              mfa: {__MODULE__, :in_any_order, [expected]},
              actual: actual)
          fail_helpfully(failure, Messages.different_elements_collections,
            left: alphabetical(actual), right: alphabetical(expected))
        :else ->
          true
      end
    end
  end

  defp alphabetical(xs) do 
    Enum.sort_by(xs, &to_string/1)
  end
    

  @doc """
  TBD
  """
  def contains(expected) when is_binary(expected) do
    fn actual ->
      if String.contains?(actual, expected),
        do: true,
        else: Failure.new(mfa: {__MODULE__, :contains, [expected]}, actual: actual)
    end
  end

  m = quote do 
    defchecker contains2(expected) do
      fn actual -> String.contains?(actual, expected) end
    end
  end

  IO.puts Macro.expand_once(m, __ENV__) |> Macro.to_string


    defchecker contains2(expected) do
      fn actual -> String.contains?(actual, expected) end
    end
  
end  
