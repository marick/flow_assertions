 defmodule FlowAssertions.CheckersTest do
  use FlowAssertions.Case
  import FlowAssertions.Checkers
  alias FlowAssertions.Define.Tabular

  describe "`in_any_order`" do
    #    [1, 3, 2]
    #    |> assert_good_enough( in_any_order([1, 2, 3]))
    setup do: [runners: Tabular.checker_runners_for(&in_any_order/1)]
    
    test "successful cases", %{runners: a} do
        # actual   checked against
      [ [1, 2, 3],   [1, 2, 3] ]     |> a.pass.()
      [ [1, 2, 3],   [3, 1, 2] ]     |> a.pass.()
    end

    test "messages", %{runners: a} do
        # actual   checked against
      [ [1, 2, 3],   [7, 1, 3] ]     |> a.fail.(~r/different elements/)
      [ [1, 2, 3],   [1, 2]    ]     |> a.fail.(~r/different lengths/)
      # A naive implementation (using MapSets) would be fooled by duplicates.
      [ [3, 3, 3],   [3, 3]    ]     |> a.fail.(~r/different lengths/)
    end

    test "the `:left` and `:right` fields are sorted", %{runners: a} do
      # That makes it easier to see how the actual differs from the expected.
      
        # actual   checked against
      [ [2, 1, 3],   [7, 1, 3] ]     |> a.fail.(left: [1, 2, 3], right: [1, 3, 7])
      [ [3, 2, 3],   [1, 2]    ]     |> a.fail.(left: [2, 3, 3], right: [1, 2])
    end
  end
end  
