defmodule FlowAssertions.Define.Tabular do
  alias FlowAssertions.{MiscA,MapA}
  import FlowAssertions.AssertionA
  import ExUnit.Assertions

  @moduledoc """
  Sketching out helper functions for tabular tests. This code will change.
  """

  def checker_runners_for(checker) do
    run = fn [actual, expected] ->
      MiscA.assert_good_enough(actual, checker.(expected))
    end
    pass = run
    fail = make_assertion_fail(run)
    plus = &MapA.assert_fields/2
    make(run, pass, fail, plus)
  end

  def assertion_runners_for(asserter) do
    arity =
      Function.info(asserter)
      |> Keyword.get(:arity)

    {run, pass} = run_and_pass(asserter, arity: arity)
    fail = make_assertion_fail(run)
    plus = &MapA.assert_fields/2
    make(run, pass, fail, plus)
  end

  defp run_and_pass(asserter, arity: 1) do
    run = asserter
    pass = fn actual -> assert run.(actual) == actual end
    {run, pass}
  end

  defp run_and_pass(asserter, _) do
    run = fn args -> apply asserter, args end
    pass = fn [actual | _] = args -> assert run.(args) == actual end
    {run, pass}
  end

  def content_runners_for(extractor) do
    run = extractor
    pass = fn actual, expected -> assert run.(actual) == expected end
    fail = make_assertion_fail(run)
    plus = &MapA.assert_fields/2
    make(run, pass, fail, plus)
  end    

  def left_is_actual(failure_producer) do
    amended_fail = 
      fn actual, expected_description ->
        failure_producer.fail.(actual, expected_description)
        |> MapA.assert_field(left: actual)
    end

    Map.put(failure_producer, :fail, amended_fail)
  end

  # ----------------------------------------------------------------------------

  defp make(run, pass, fail, plus) do
    %{pass: pass,
      fail: fail,
      plus: plus,
      inspect:    fn actual ->          run.(actual) |> IO.inspect end,
      inspect_:   fn actual, _ ->       run.(actual) |> IO.inspect end,
      inspect__:  fn actual, _, _ ->    run.(actual) |> IO.inspect end,
      inspect___: fn actual, _, _, _ -> run.(actual) |> IO.inspect end,

      run: run
    }
  end

  defp make_assertion_fail(run) do
    fn
      actual, %Regex{} = regex ->
        assertion_fails(regex, fn -> run.(actual) end)
      actual, message when is_binary(message) ->
        assertion_fails(message, fn -> run.(actual) end)
      actual, opts when is_list(opts) ->
        assertion_fails(~r/.*/, opts, fn -> run.(actual) end)
    end
  end

end
