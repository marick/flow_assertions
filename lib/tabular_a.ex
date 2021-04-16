defmodule FlowAssertions.TabularA do
  alias FlowAssertions.MiscA
  import FlowAssertions.Define.BodyParts

  @moduledoc """
  Builders that create functions tailored to tabular tests.

  Here are some tabular tests for how 
  `Previously.parse` copes with one of its keyword arguments:

      [insert:  :a                  ] |> expect.([een(a: Examples)])
      [insert: [:a, :b      ]       ] |> expect.([een(a: Examples), een(b: Examples)])
      [insert: [:a,  b: List]       ] |> expect.([een(a: Examples), een(b: List)])

      [insert: :a, insert: [b: List]] |> expect.([een(a: Examples), een(b: List)])
    
      [insert: een(a: Examples)     ] |> expect.([een(a: Examples)])


  The `expect` function above was created with:

      expect = TabularA.run_and_assert(
        &(Pnode.Previously.parse(&1) |> Pnode.EENable.eens))

  There is also a function that allows assertions about exceptions to be written in a tabular style:

      raises = TabularA.run_for_exception(&case_clause/2)
      [3, 3] |> raises.(CaseClauseError)

  ## Related code

  You can find similar builders in
  `FlowAssertions.Define.Tabular`. They produce functions used to test
  assertions (like the ones in this package).

  ## Beware the typo

  I make this kind of typo a lot:

      [2, 2] |> expect("The sum is 4")

  There should be a period after `expect`. The result (as of Elixir 1.11) is

      ** (CompileError) test.exs:42: undefined function expect/2
  """

  @doc """
  Hide repeated code inside an `expect` function, allowing concise tabular tests.

  The first argument is a function that generates a value. It may just
  be the function under test:

      expect = TabularA.run_and_assert(&Enum.take/2)

  Quite often, however, it's a function that does some extra work for
  each table row.
  For example, the following
  extracts just the part of the result that needs to be checked. Because of that,
  the table is less cluttered.

      expect = TabularA.run_and_assert(
        &(Pnode.Previously.parse(&1) |> Pnode.EENable.eens))

  Because the above function has a single argument, `expect` is called like
  this:

      :a |> expect.([een(a: Examples)])

  Functions that take two or more arguments need them to be enclosed
  in a list or tuple:

      [:a, :b] |> expect.([een(:a, b: Examples)])
      {:a, :b} |> expect.([een(:a, b: Examples)])

  (I use tuples when some of the arguments are lists. It's easier to read.)

  By default, correctness is checked with `===`. You can override that
  by passing in a second function:

      expect = TabularA.run_and_assert(
        &Common.FromPairs.extract_een_values/1,
        &assert_good_enough(&1, in_any_order(&2)))

  In the above case, the second argument is a function that takes both a
  computed and an expected value. You can instead provide a function that only
  takes the computed value. In such a case, I typically call the resulting
  function `pass`:

      pass = TabularA.run_and_assert(
        &case_clause/1,
        &(assert &1 == "one passed in"))

      1 |> pass.()

  Beware: a common mistake is to use a predicate like `&(&1 == "one passed in")`.
  Without an assertion, the generated `pass` function can never fail.
  """
  
  def run_and_assert(result_producer, asserter \\ &MiscA.assert_equal/2) do
    runner = run(result_producer)

    step1 = fn input ->
      try do
        runner.(input)
      rescue
        ex in [ExUnit.AssertionError] ->
          reraise ex, __STACKTRACE__
        ex ->
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
  A more concise version of `ExUnit.Assertions.assert_raise/3`, suitable for tabular tests.

  A typical use looks like this:

      "some error value" |> raises.("some error message")

  Creation looks like this:

      raises = TabularA.run_for_exception(&function_under_test/1)

  As with `FlowAssertions.TabularA.run_and_assert/2`, multiple arguments are
  passed in a list or tuple:

      [-1, 3] |> raises.(~r/no negative values/)

  As shown above, the expected message may be matched by a `String` or `Regex`.
  You can also check which exception was thrown:

      [3, 3] |> raises.(CaseClauseError)

  If you want to check both the type and message, you have to enclose them
  in a list:

      [3, 3] |> raises.([CaseClauseError, ~R/no case clause/])
      
  Note that you can put multiple regular expressions in the list to check different
  parts of the message.

  The generated function returns the exception, so it can be piped to later
  assertions:

      [3, 3] |> raises.([CaseClauseError, ~R/no case clause/])
             |> assert_field(term: [3, 3])
  """
  def run_for_exception(result_producer) do
    runner = run(result_producer)
    fn
      input, check when is_list(check) -> run_for_raise(runner, input, check)
      input, check -> run_for_raise(runner, input, [check])
    end
  end

  @doc """
  Return the results of both `run_and_assert` and `run_for_exception`.

      {expect, raises} = TabularA.runners(&case_clause/2)

  The optional second argument is passed to `expect`.
  """
  def runners(result_producer, asserter \\ &MiscA.assert_equal/2) do
    {run_and_assert(result_producer, asserter), run_for_exception(result_producer)}
  end

  # ----------------------------------------------------------------------------

  defp run(result_producer) do
    case arity(result_producer) do
      1 -> 
        fn arg -> apply result_producer, [arg] end
      n ->
        fn args -> apply_multiple(result_producer, args, n) end
    end
  end

  defp apply_multiple(result_producer, args, n) when is_list(args) do
    elaborate_assert(
      length(args) == n,
      arity_description(n, length(args)),
      left: args)
    apply result_producer, args
  end
  
  defp apply_multiple(result_producer, args, n) when is_tuple(args), 
    do: apply_multiple(result_producer, Tuple.to_list(args), n)

  defp apply_multiple(_result_producer, args, n) do
    elaborate_flunk(arity_description(n, 1), left: args)
  end

  defp arity_description(n, not_n),
    do: "The result producer takes #{n} arguments, not #{not_n}"

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
