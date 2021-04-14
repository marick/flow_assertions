defmodule FlowAssertions.Tabular do
  alias FlowAssertions.MiscA
#  import ExUnit.Assertions
  import FlowAssertions.Define.BodyParts

  def run(result_producer) do
    case arity(result_producer) do
      1 -> 
        fn arg -> apply result_producer, [arg] end
      _n ->
        fn args -> apply result_producer, args end
    end
  end

  def expect(result_producer, asserter \\ &MiscA.assert_equal/2) do
    runner = run(result_producer)
    fn input, expected ->
      result =
        try do
          runner.(input)
        rescue ex ->
          name = ex.__struct__
          elaborate_flunk("Unexpected exception #{name}", left: ex)
        end
      asserter.(result, expected)
    end
  end

  def raises(result_producer) do
    runner = run(result_producer)
    fn
      input, check when is_list(check) -> run_for_raise(runner, input, check)
      input, check -> run_for_raise(runner, input, [check])
    end
  end


  defp run_for_raise(runner, input, checks) do
    try do
      {:no_raise, runner.(input)}
    rescue 
      ex ->
        for expected <- checks do
          cond do
            is_atom(expected) ->
              actual = ex.__struct__
              elaborate_assert(actual == expected,
                "An unexpected exception was raised",
                left: actual,
                right: expected)
            expected ->
              msg = Exception.message(ex)
              elaborate_assert(MiscA.good_enough?(msg, expected),
                "The exception message was incorrect",
                left: msg, right: expected)
          end
        end
        ex
    else
      {:no_raise, result} ->
        msg = "An exception was expected, but a value was returned"
      elaborate_flunk(msg, left: result)
    end
  end

      
  

  #       {:error, run.(arg)}
  #     rescue
  #       ex -> :ok
  #     else
  #       {:error, result} ->
  #         elaborate_flunk("No exception was raised", left: result)
  #     end
        
        
    

  defp arity(function), do: Function.info(function) |> Keyword.get(:arity)

  # def runners(result_producer, checker() do

  #   expect = fn arg, expected ->
  #     MiscA.assert_equal(run.(arg), expected)
  #   end

  #   fail = fn arg ->
  #     try do
  #       {:error, run.(arg)}
  #     rescue
  #       ex -> :ok
  #     else
  #       {:error, result} ->
  #         elaborate_flunk("No exception was raised", left: result)
  #     end
  #   end
        
  #   {expect, fail}
  # end
end
