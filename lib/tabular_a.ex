defmodule FlowAssertions.TabularA do
  alias FlowAssertions.MiscA
  import FlowAssertions.Define.BodyParts

  @moduledoc """
  Builders that create functions tailored to tabular tests.

  Here's a example of some tabular tess.

      [insert:  :a                  ] |> expect.([een(a: Examples)])
      [insert: [:a, :b      ]       ] |> expect.([een(a: Examples), een(b: Examples)])
      [insert: [:a,  b: List]       ] |> expect.([een(a: Examples), een(b: List)])

      [insert: :a, insert: [b: List]] |> expect.([een(a: Examples), een(b: List)])
    
      [insert: een(a: Examples)     ] |> expect.([een(a: Examples)])


  The `expect` function above was created with 

      expect = TabularA.expect(
        &(Pnode.Previously.parse(&1) |> Pnode.EENable.eens))

  There is also a function that puts assertions about exceptios in a tabular style:

      raises = TabularA.raises(&case_clause/2)
      [3, 3] |> raises.(CaseClauseError)

  You can find similar builders in `FlowAssertions.Define.Tabular`. They
  can be used to test functions that raise `ExUnit.AssertionError` values.

  ## Beware the typo

  The most common mistake *I* make with this library is this kind of typo:

      [2, 2] |> expect("The sum is 4")

  There should be a period after `expect`. The result (as of Elixir 1.11) is

      ** (CompileError) test.exs:42: undefined function expect/2
  """

  @doc """
  Hide repeated code inside an `expect` function, allowing concise tabular tests.

  The first argument is a function that generates a value. It may just
  be the function under test:

      expect = TabularA.expect(&Enum.take/2)

  Quite often, however, it's a function that does some calculation
  common to all the table rows, then calls the function under
  test (in the following, `Pnode.EENable.eens`):

      expect = TabularA.expect(
        &(Pnode.Previously.parse(&1) |> Pnode.EENable.eens))

  Because the above function has a single argument, `expect` is called like
  this:

      :a |> expect.([een(a: Examples)])

  If it had had two or more arguments, those arguments would have had to be passed
  in a list:

      [:a, :b] |> expect.([een(:a, b: Examples)])

  By default, correctness is checked with `===`. You can override that
  by passing in a second function:

      expect = TabularA.expect(
        &Common.FromPairs.extract_een_values/1,
        &assert_good_enough(&1, in_any_order(&2)))

  In the above case, the second argument is a function that takes both an
  actual and expected value. You can instead provide a function that only
  takes the actual value. In such a case, I typically call the resulting
  function `pass`:

      pass = TabularA.expect(
        &case_clause/1,
        &(assert &1 == "one passed in"))

      1 |> pass.()

  Beware: a common mistake is to pass in a predicate like `&(&1 == "one passed in")`.
  Without an assertion, `pass` can never fail.
  """
  
  def expect(result_producer, asserter \\ &MiscA.assert_equal/2) do
    runner = run(result_producer)

    step1 = fn input ->
      try do
        runner.(input)
      rescue ex ->
          name = ex.__struct__
        elaborate_flunk("Unexpected exception #{name}", left: ex)
      end
    end

    case arity(asserter) do
      1 ->
        fn input ->
          step1.(input) |> asserter.()
        end
      _ ->
        fn input, expected ->
          step1.(input) |> asserter.(expected)
        end
    end
  end

  @doc """
  A more concise version of `assert_raise`, suitable for tabular tests.

  A typical use looks like this:

      "some error value" |> raises.("some error message")

  Creation looks like this:

        raises = TabularA.raises(&function_under_test/1)

  As with `FlowAssertions.TabularA.expect/2`, multiple arguments are
  passed in a list:

      [-1, 3] |> raises.(~r/no negative values/)

  As shown above, the expected message may be matched by a `String` or `Regex`.
  You can also check which exception was thrown:

      [3, 3] |> raises.(CaseClauseError)

  If you want to check both the type and message, you have to enclose them
  in a list:

      [3, 3] |> raises.([CaseClauseError, ~R/no case clause/])
      
  Note that you can use multiple regular expressions to check different
  parts of the message.

  The generated function returns the exception, so it can be piped to later
  assertions:

      [3, 3] |> raises.([CaseClauseError, ~R/no case clause/])
             |> assert_field(term: [3, 3])
  """
  def raises(result_producer) do
    runner = run(result_producer)
    fn
      input, check when is_list(check) -> run_for_raise(runner, input, check)
      input, check -> run_for_raise(runner, input, [check])
    end
  end

  @doc """
  Return the results of both `expect` and `raises`.

      {expect, raises} = TabularA.runners(&case_clause/2)

  The optional second argument is passed to `expect`.
  """
  def runners(result_producer, asserter \\ &MiscA.assert_equal/2) do
    {expect(result_producer, asserter), raises(result_producer)}
  end

  # ----------------------------------------------------------------------------

  defp run(result_producer) do
    case arity(result_producer) do
      1 -> 
        fn arg -> apply result_producer, [arg] end
      _n ->
        fn args -> apply result_producer, args end
    end
  end

  defp arity(function), do: Function.info(function) |> Keyword.get(:arity)

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
end
