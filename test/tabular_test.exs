defmodule FlowAssertions.Define.TabularTests do
  use FlowAssertions.Case
  import FlowAssertions.Define.Tabular

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
end