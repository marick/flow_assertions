defmodule FlowAssertions.EnumATest do
  use FlowAssertions.Case

  @moduledoc """
  Assertions for values that satisfy the `Enum` protocol.
  """

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

  test "assert_empty" do
    assert assert_empty([]) == []
    assert assert_empty(%{}) == %{}
    
    assertion_fails_with_diagnostic(
      ["Expected an empty Enum"],
      fn -> assert_empty([1]) end)
    
    assertion_fails_with_diagnostic(
      ["Expected an empty Enum"],
      fn -> assert_empty(%{a: 2}) end)
    end
end
  
