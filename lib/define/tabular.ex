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
    run = asserter
    pass = fn actual -> assert run.(actual) == actual end
    fail = make_assertion_fail(run)
    plus = &MapA.assert_fields/2
    make(run, pass, fail, plus)
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
      view:    fn actual ->          run.(actual) end,
      view_:   fn actual, _ ->       run.(actual) end,
      view__:  fn actual, _, _ ->    run.(actual) end,
      view___: fn actual, _, _, _ -> run.(actual) end,
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
