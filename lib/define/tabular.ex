defmodule FlowAssertions.Define.Tabular do
  alias FlowAssertions.MiscA
  import FlowAssertions.AssertionA

  @moduledoc """
  Sketching out helper functions for tabular tests. This code will change.
  """

  def runners_for(checker) do
    run = fn [actual, expected] ->
      MiscA.assert_good_enough(actual, checker.(expected))
    end
    fail = fn
      condensed_assertion, %Regex{} = regex ->
        assertion_fails(regex, fn -> run.(condensed_assertion) end)
      condensed_assertion, message when is_binary(message) ->
        assertion_fails(message, fn -> run.(condensed_assertion) end)
      condensed_assertion, opts when is_list(opts) ->
        assertion_fails(~r/.*/, opts, fn -> run.(condensed_assertion) end)
    end

    %{pass: run,
      fail: fail,
      view:    fn args ->          run.(args) end,
      view_:   fn args, _ ->       run.(args) end,
      view__:  fn args, _, _ ->    run.(args) end,
      view___: fn args, _, _, _ -> run.(args) end,
    }
  end
end
