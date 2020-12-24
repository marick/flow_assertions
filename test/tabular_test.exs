defmodule FlowAssertions.Define.TabularTests do
  use FlowAssertions.Case
  import FlowAssertions.Define.{Tabular,BodyParts}

  describe "fail" do
    test "variant argument lists" do 
      a = assertion_runners_for(&assert_equal/2)
      msg = "Assertion with === failed"
      
      ["a", "b"] |> a.fail.(msg)
      ["a", "b"] |> a.fail.(left: "a", right: "b")
      ["a", "b"] |> a.fail.(message: msg, left: "a", right: "b")

      ["a", "b"] |> a.fail.(msg)
                 |> a.plus.(left: "a", right: "b")

      # Note that left and right are not string versions
      [ ["a", "a"], "b"] |> a.fail.(message:      msg, left: ["a", "a"])
      # The message is always compared specially:
      [ ["a", "a"], "b"] |> a.fail.(message: ~r/with/, left: ["a", "a"])
    end
  end


  describe "left_is_actual" do
    def bad_one_arg(_   ), do: elaborate_flunk("message", left: "weird")
    def bad_two_arg(_, _), do: elaborate_flunk("message", left: "weird")

    def fails(f) do 
      assertion_fails("Field `:left` has the wrong value",
        [left: "weird", right: :error],
        f)
    end
    
    test "one argument asserter" do
      x = assertion_runners_for(&assert_equal/2) |> left_is_actual
      [1, 2] |> x.fail.("Assertion with === failed")
      

      
      a = assertion_runners_for(&bad_one_arg/1) |> left_is_actual

      fails(fn -> :error |> a.fail.("message") end)
    end

    test "two argument asserter" do
      a = assertion_runners_for(&bad_two_arg/2) |> left_is_actual

      fails(fn -> [:error, :other] |> a.fail.("message") end)
    end
  end
end
