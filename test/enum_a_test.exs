defmodule FlowAssertions.EnumATest do
  use ExUnit.Case, async: true
  use FlowAssertions

  describe "assert_singleton" do 
    test "typical use: lists" do
      assert assert_singleton([1]) == [1]
      
      assertion_fails_with_diagnostic(
        ["Expected a single element"],
        fn -> assert_singleton([]) end)
      
      assertion_fails_with_diagnostic(
        ["Expected a single element"],
        fn -> assert_singleton([1, 2]) end)
    end

    test "any Enum can be used" do
      assert assert_singleton(%{a: 1}) == %{a: 1}

      assertion_fails_with_diagnostic(
        ["Expected a single element"],
        fn -> assert_singleton(%{}) end)
      
      assertion_fails_with_diagnostic(
        ["Expected a single element"],
        fn -> assert_singleton(%{a: 1, b: 2}) end)
    end
  end

  describe "singleton_content" do 
    test "typical use: lists" do
      assert singleton_content([1]) == 1
      
      assertion_fails_with_diagnostic(
        ["Expected a single element"],
        fn -> singleton_content([]) end)
      
      assertion_fails_with_diagnostic(
        ["Expected a single element"],
        fn -> singleton_content([1, 2]) end)
    end

    test "any Enum can be used" do
      assert singleton_content(%{a: 1}) == {:a, 1}

      assertion_fails_with_diagnostic(
        ["Expected a single element"],
        fn -> singleton_content(%{}) end)
      
      assertion_fails_with_diagnostic(
        ["Expected a single element"],
        fn -> singleton_content(%{a: 1, b: 2}) end)
    end
  end 
  
end
  
