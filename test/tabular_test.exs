defmodule FlowAssertions.TabularTests do
  use FlowAssertions.Case
  alias FlowAssertions.Tabular

  defp case_clause(x) do 
    case x do
      1 -> "one passed in"
      2 -> "two passed in"
    end
  end
  
  defp case_clause(x, y) do 
    case [x, y] do
      [1, 1] -> "one passed in"
      [2, 2] -> "two passed in"
    end
  end

  describe "creation of `expect`" do 
    test "single argument function" do
      expect = Tabular.expect(&case_clause/1)
    
      1 |> expect.("one passed in")

      assertion_fails("Assertion with === failed",
        [left: "two passed in",
         right: "one passed in"],
        fn -> 
          2 |> expect.("one passed in")
        end)

      assertion_fails(~r/CaseClauseError/,
        [left: %CaseClauseError{term: 3}],
        fn -> 
          expect.(3, "unused")
        end)
    end

    test "n-argument function" do
      expect = Tabular.expect(&case_clause/2)
    
      [1, 1] |> expect.("one passed in")

      assertion_fails("Assertion with === failed",
        [left: "two passed in",
         right: "one passed in"],
        fn -> 
          [2, 2] |> expect.("one passed in")
        end)
    end

    test "a second argument provides the checker" do
      expect = Tabular.expect(&case_clause/2, &assert_good_enough/2)
    
      [1, 1] |> expect.(~r/one passed/)
      
      assertion_fails("Regular expression didn't match",
        [left: "two passed in",
         right: ~r/one/],
        fn -> 
          [2, 2] |> expect.(~r/one/)
        end)
    end
  end

  describe "raises" do
    test "the zero-argument case" do
      raises = Tabular.raises(&case_clause/1)

      3 |> raises.([]) |> assert_equal(%CaseClauseError{term: 3})

      assertion_fails("An exception was expected, but a value was returned",
        [left: "two passed in"],
        fn ->
          2 |> raises.([])
        end)
    end

    test "one argument" do
      raises = Tabular.raises(&case_clause/2)

      [3, 3] |> raises.(CaseClauseError)

      assertion_fails("An unexpected exception was raised",
        [left: CaseClauseError, right: RuntimeError],
        fn -> 
          [3, 3] |> raises.(RuntimeError)
        end)

      assertion_fails("The exception message was incorrect",
        [left: "no case clause matching: [3, 3]", right: "foo"],
        fn -> 
          [3, 3] |> raises.("foo")
        end)

      # `raises` allows regexps
      [3, 3] |> raises.(~r/no case/)
      
      assertion_fails("The exception message was incorrect",
        [left: "no case clause matching: [3, 3]", right: ~r/cccc/],
        fn -> 
          [3, 3] |> raises.(~r/cccc/)
        end)
    end


    test "N arguments" do
      raises = Tabular.raises(&case_clause/2)

      [3, 3] |> raises.([CaseClauseError, ~R/no case clause/])

      assertion_fails("An unexpected exception was raised",
        [left: CaseClauseError, right: RuntimeError],
        fn -> 
          [3, 3] |> raises.([~r/no case clause/, RuntimeError])
        end)

      assertion_fails("The exception message was incorrect",
        [left: "no case clause matching: [3, 3]", right: "foo"],
        fn -> 
          [3, 3] |> raises.([CaseClauseError, "foo"])
        end)
    end
  end

  describe "a combination" do
    test "creating both `expect` and `raises` at the same time" do
      {expect, raises} =  Tabular.runners(&case_clause/2, &assert_good_enough/2)

      assertion_fails("Regular expression didn't match",
        [left: "two passed in",
         right: ~r/one/],
        fn -> 
          [2, 2] |> expect.(~r/one/)
        end)

      assertion_fails("An unexpected exception was raised",
        [left: CaseClauseError, right: RuntimeError],
        fn -> 
          [3, 3] |> raises.(RuntimeError)
        end)
    end
  end
end
