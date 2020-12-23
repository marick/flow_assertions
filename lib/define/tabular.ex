defmodule FlowAssertions.Define.Tabular do
  alias FlowAssertions.{MiscA,MapA}
  import FlowAssertions.AssertionA
  import ExUnit.Assertions

  @moduledoc """
  Generate "runners" used in tabular tests of assertions and
  assertion-like functions. 

  A typical example:

        a = assertion_runners_for(&assert_equal/2)
    
        ["value", "value"] |> a.pass.()
        ["value", "     "] |> a.fail.("Assertion with === failed")
                           |> a.plus.(left: "value", right: "     ")


  `assert_equal` takes two arguments, and those are passed to the runner
  functions (`pass` and `fail`) in a list. 
  If there's only a single argument, the enclosing list can be omitted:

        a = assertion_runners_for(&assert_ok/1)

        :ok     |> a.pass.()
        :error  |> a.fail.(Messages.not_ok)

  The functions created are, unless noted in the individual descriptions below,
  these:

  * **pass**: A runner that applies a function to arguments and checks for
    success.
    What, precisely, counts as success depends on the function under test. For
    a flow assertion, success means returning its first argument.
    
    In the examples above, `pass` took only one argument (the value on
    the left side of the `|>`). That's because the expected output of
    `assert_ok` is trivial.
    
    
    In other cases, you must give the expected output to `pass`. That looks
    like this:

        test "ok_content" do
          a = content_runners_for(&ok_content/1)

          {:ok, "content"}    |> a.pass.("content")
          ...

  * **fail**: takes an argument that is matched against an 
    `AssertionError`. 

     * A string, which must match the error message exactly. 
     * A regular expression, like `~r/different lengths/`, which
       can match part of the message.
     * A keyword list, which is checked with `FlowAssertions.MapA.assert_fields/2`
       A typical use might be:

            [ {1, 2}, 3 ] |> a.fail.(left: {1, 2}, right: 3)

       Note that the left and right values are the true values from `ExUnit.AssertionError`, not `inspect`ed versions.
       If the error message is also to be tested, it should be given in keyword form:

          a.fail.(left: "a", right: "bb", message: ~r/different lengths/)

  * **plus**: Provides an arguably nicer way to check both the `:message` and
    other `AssertionError` fields. It's appended
    to `fail` like this:

         [datetime] |> a.fail.(Messages.wrong_struct_name(NaiveDateTime, Date))
                    |> a.plus.(left: datetime)

  * **inspect_**. This is a function to help with test-writing workflow. It
    mainly exists because it's hard for me to get the display of error information right
    without looking at it. That is, a check like this:
    
         [ [1, 2, 3],   [7, 1, 3] ]     |> a.fail.(~r/different elements/)
                                        |> a.plus.(...)


    is likely to come from looking at this:

         <picture here>

    ... and then tweaking the message and
    maybe the `code:`, `left:`, or `right:` fields. I only "solidify" the
    final design in a test after everything looks right.

    Normally, that would involve writing throwaway code, but `inspect_` avoids
    that. Once I pick test inputs (the values before the `|>`),
    I just write this:
    
         [ [1, 2, 3],   [7, 1, 3] ]     |> a.inspect_.(~r/a first message version/)
                                             ^^^^^^^^

    The trailing `_` indicates that `inspect_` is replacing a function that
    takes one argument. Use `inspect` to replace a function with
    zero arguments, like `pass`. 
  """

  # ----------------------------------------------------------------------------
  
  @doc """
  Create checking functions for flow-style assertions.

      a = assertion_runners_for(&assert_empty/1)

  `asserter` should be a function that either raises an `AssertionError`
  or returns its first argument. 

  `pass` and `fail` are as described above.
  """
  def assertion_runners_for(asserter),
    do: runners(:returns_first_arg, asserter)

  @doc """
  Adjust the results of a `fail` function to assert a value for `left:`. 

  Suppose you create tabular functions for `FlowAssertions.MiscA.ok_content`
  like this:

        a = content_runners_for(&ok_content/1) |> left_is_actual
                                               ^^^^^^^^^^^^^^^^^

  Then a table entry like this:

        :ok |> a.fail.(Messages.not_ok_tuple)

  ... will check that the `:left` value of the `AssertionError` is `:ok`. (That is,
  the argument given to `ok_content`). There is no need to add a
  `|> plus.(left: :ok)`. 

  Note: the original function (the `asserter` or `extractor`) must take only
  a single argument.
  """
  def left_is_actual(failure_producer) do
    amended_fail = 
      fn actual, expected_description ->
        failure_producer.fail.(actual, expected_description)
        |> MapA.assert_field(left: actual)
    end

    Map.put(failure_producer, :fail, amended_fail)
  end

  # ----------------------------------------------------------------------------
  @doc """
  Create checking functions for regular Elixir assertions.

  `asserter` should be a function that raises an `AssertionError` or 
  returns an unspecified value. `pass`, then, always succeeds if it's
  given a value.
  """
  def nonflow_assertion_runners_for(asserter),
    do: runners(:return_irrelevant, asserter)

  # ----------------------------------------------------------------------------
  @doc """
  Create checking functions for functions that either return part of a compound
  value or raise an `AssertionError`. 

  Consider `FlowAssertions.MiscA.ok_content`:

       a = content_runners_for(&ok_content/1)
       
       {:ok, "content"}    |> a.pass.("content")
       :ok                 |> a.fail.(Messages.not_ok_tuple)
       {:error, "content"} |> a.fail.(Messages.not_ok_tuple)

  Note that `pass` takes a single value.
  """
  
  def content_runners_for(extractor), do: runners(:returns_part, extractor)

  # ----------------------------------------------------------------------------

  @doc """
  Create checking functions for functions like those in `FlowAssertions.Checkers`. 

        a = checker_runners_for(&in_any_order/1)]
          # actual   checked against

        [ [1, 2, 3],   [1, 2, 3] ]     |> a.pass.()
        [ [1, 2, 3],   [7, 1, 3] ]     |> a.fail.(~r/different elements/)

  `checker` should be a function that can return a
  `FlowAssertions.Define.Defchecker.Failure` value`. As for what that
  means... Well, as of late 2020, checker creation is not documented.
  """
  
  def checker_runners_for(checker), do: runners(:returns_informative_failure, checker)

  # ----------------------------------------------------------------------------

  def runners(key, f), do: start(key, f) |> finish
  
  defp start(:returns_first_arg, asserter) do
    case arity(asserter) do
      1 -> 
        run = asserter
        pass = fn actual -> assert run.(actual) == actual end
        %{run: run, pass: pass, arity: 1}
      arity ->
        run = fn args -> apply asserter, args end
        pass = fn [actual | _] = args -> assert run.(args) == actual end
        %{run: run, pass: pass, arity: arity}
    end
  end


  defp start(:return_irrelevant, asserter) do 
    case arity(asserter) do
      1 ->
        run = asserter
        %{run: run, pass: run, arity: 1}
      arity ->
        run = fn args -> apply asserter, args end
        %{run: run, pass: run, arity: arity}
    end
  end
  
  defp start(:returns_part, extractor) do 
    case arity(extractor) do
      1 ->
        run = extractor
        pass = fn actual, expected -> assert run.(actual) == expected end
        %{run: run, pass: pass, arity: 1}
      _arity -> 
        flunk("Only arity 1 is allowed")
    end
  end

  defp start(:returns_informative_failure, checker) do
    case arity(checker) do
      1 ->
        run = fn [actual, expected] ->
          MiscA.assert_good_enough(actual, checker.(expected))
        end
        pass = run
        %{run: run, pass: pass, arity: 1}
      _arity -> 
        flunk("Only arity 1 is allowed")
    end            
  end
  
  # ----------------------------------------------------------------------------

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

  defp arity(function), do: Function.info(function) |> Keyword.get(:arity)

  defp add_inspect(runners) do
    run = runners.run

    Map.merge(
      runners,
      %{
        inspect:    fn actual ->          run.(actual) |> IO.inspect end,
        inspect_:   fn actual, _ ->       run.(actual) |> IO.inspect end,
        # These are probably useless, but whatever.
        inspect__:  fn actual, _, _ ->    run.(actual) |> IO.inspect end,
        inspect___: fn actual, _, _, _ -> run.(actual) |> IO.inspect end,
      })
  end

  defp finish(runners) do 
    runners
    |> Map.put(:fail, make_assertion_fail(runners.run))
    |> Map.put(:plus, &MapA.assert_fields/2)
    |> add_inspect
  end
  
  
end
