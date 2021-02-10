 defmodule FlowAssertions.CheckersTest do
  use FlowAssertions.Case
  import FlowAssertions.Checkers

  describe "`in_any_order`" do
    #    [1, 3, 2]
    #    |> assert_good_enough( in_any_order([1, 2, 3]))
    setup do: [runners: checker_runners_for(&in_any_order/1)]
    
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

    defmodule Unsortable do
      defstruct [:a]
    end

    test "`in-any-order` fails nicely when the argument is not sortable" do 
      unsortable = %Unsortable{a: 1}

      assertion_fails("The two collections have different elements",
        [left:  [%FlowAssertions.CheckersTest.Unsortable{a: 1}, 1],
         right: [%FlowAssertions.CheckersTest.Unsortable{a: 1}, 2]],
        fn -> 
          assert_good_enough([1, unsortable], in_any_order([2, unsortable]))
        end)
    end
  end

  describe "has_slice" do
    setup do: [runners: checker_runners_for(&has_slice/1)]
    
   test "strings", %{runners: a} do
      ["a", "" ]  |> a.pass.()
      ["a", "a"]  |> a.pass.()
      ["a", "b"]  |> a.fail.(~s/Checker `has_slice("b")` failed/)
      ["", "a" ]  |> a.fail.(~s/Checker `has_slice("a")` failed/)
                  |> a.plus.(left: "")

      ["brian", "ian"] |> a.pass.()
   end
    
   test "lists", %{runners: a} do
      [[ ], [ ]]  |> a.pass.()
      [[1], [ ]]  |> a.pass.()
      [[1], [1]]  |> a.pass.()
      [[ ], [1]]  |> a.fail.(~s/Checker `has_slice([1])` failed/)
                  |> a.plus.(left: [])
      
      [[1, 2, 3], [1]]  |> a.pass.()
      [[1, 2, 3], [1, 2]]  |> a.pass.()
      [[1, 2, 3], [1, 2, 3]]  |> a.pass.()

      [[1, 2, 3], [2]]  |> a.pass.()
      [[1, 2, 3], [2, 3]]  |> a.pass.()
      [[1, 2, 3], [2, 3, 1]]  |> a.fail.(~s/Checker `has_slice([2, 3, 1])` failed/)

      [[1, 2, 3], [3]]  |> a.pass.()
      [[1, 2, 3], [3, 1]]  |> a.fail.(~s/Checker `has_slice([3, 1])` failed/)
      [[1, 2, 3], [3, 1, 2]]  |> a.fail.(~s/Checker `has_slice([3, 1, 2])` failed/)
   end
    
  end
end  
