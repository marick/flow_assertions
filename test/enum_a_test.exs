defmodule FlowAssertions.EnumATest do
  use FlowAssertions.Case

  @moduledoc """
  Assertions for values that satisfy the `Enum` protocol.
  """

  describe "assert_singleton" do 
    test "typical use: lists" do
      assert assert_singleton([1]) == [1]

      assertion_fails(
        Messages.expected_1_element,
        [left: []],
        fn -> assert_singleton([]) end)
      
      assertion_fails(
        Messages.expected_1_element,
        fn -> assert_singleton([1, 2]) end)
    end

    test "any Enum can be used" do
      assert assert_singleton(%{a: 1}) == %{a: 1}

      assertion_fails(
        Messages.expected_1_element,
        fn -> assert_singleton(%{}) end)
      
      assertion_fails(
        Messages.expected_1_element,
        fn -> assert_singleton(%{a: 1, b: 2}) end)
    end
  end

  describe "singleton_content" do 
    test "typical use: lists" do
      assert singleton_content([1]) == 1
      
      assertion_fails(
        Messages.expected_1_element,
        [left: []],
        fn -> singleton_content([]) end)
      
      assertion_fails(
        Messages.expected_1_element,
        fn -> singleton_content([1, 2]) end)
    end

    test "any Enum can be used" do
      assert singleton_content(%{a: 1}) == {:a, 1}

      assertion_fails(
        Messages.expected_1_element,
        fn -> singleton_content(%{}) end)
      
      assertion_fails(
        Messages.expected_1_element,
        fn -> singleton_content(%{a: 1, b: 2}) end)
    end

    test "non-Enum case fails" do
      assertion_fails(Messages.not_enumerable,
        [left: "sososo"],
        fn ->
          singleton_content("sososo")
        end)
    end
  end

  test "assert_enumerable" do
    assert assert_enumerable([]) == []

    assertion_fails(Messages.not_enumerable,
      [left: 1],
      fn -> 
        assert_enumerable(1)
      end)
  end

  test "assert_empty" do
    assert assert_empty([]) == []
    assert assert_empty(%{}) == %{}

    assertion_fails(
      Messages.expected_no_element,
      fn -> assert_empty([1]) end)
    
    assertion_fails(
      Messages.expected_no_element,
      fn -> assert_empty(%{a: 2}) end)

    assertion_fails(
      Messages.not_enumerable,
      [left: 3],
      fn -> 
        assert_empty(3)
      end)
  end

end
  
