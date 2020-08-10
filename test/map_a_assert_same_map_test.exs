defmodule FlowAssertions.MapAAssertSameMapTest do
  use ExUnit.Case, async: true
  use FlowAssertions
  alias FlowAssertions.Define.Messages
  import FlowAssertions.AssertionA

  defstruct name: nil # Used for typo testing

  describe ":ignoring" do
    test "can ignore fields" do
      old = %{stable: 1, field2: 22222}
      new =  %{stable: 1, field2: 2}

      # No error
      assert assert_same_map(new, old, ignoring: [:field2]) == new

      # Given that these assertions are likely to be multi-line and
      # ExUnit only shows the first line, it's probably more
      # informative to show the actual failing comparison, which
      # looks like this:
      #
      #     assert Map.drop(new, ignoring_keys) == Map.drop(old, ignoring_keys)
      #
      # That's not tested, because it's too much trouble.

      assertion_fails(
        Messages.stock_equality,
        [left: %{field2: 2}, right: %{field2: 22222}],
        fn ->
          assert_same_map(new, old, ignoring: [:stable])
        end)
    end

    test "':ignoring' fields must be present in new *struct*" do
      irrelevant = %__MODULE__{name: 1}

      assertion_fails(
        ~r/Test error: there is no key `:extra` in FlowAssertions.Map.*Test/,
        fn -> 
          assert_same_map(irrelevant, irrelevant, ignoring: [:extra])
        end)
    end
  end

  describe ":comparing option" do
    test "you can't use it with `:ignoring`" do
      map = %{ignoring: 1,  comparing: [1]}
      
      assertion_fails(
        "Test error: you can't use both `:ignoring` and `comparing",
        fn ->
          assert_same_map(map, map, ignoring: [:ignoring], comparing: [:stable])
        end)
    end
    
    test "partial copy comparison" do
      old = %{stable: 1,  change: [1]}
      new =  %{stable: 1, change: []}
      
      assert_same_map(new, old, comparing: [:stable])
      
      assertion_fails(
        Messages.stock_equality,
        [left: %{change: []}, right: %{change: [1]}],
        fn -> 
          assert_same_map(new, old, comparing: [:change])
        end)
    end
  end

    
  describe ":except" do
    test "can do `assert_fields` comparisons" do
      old = %{stable: 1, important_change: 22222}
      new =  %{stable: 1, important_change: 2}

      assert_same_map(new, old, except: [important_change: 2])

      assertion_fails(
        "Field `:important_change` has the wrong value",
        [left: 2, right: 33],
        fn ->
          assert_same_map(new, old, except: [important_change: 33])
        end)
    end

    test "`:except` assertions can include predicates" do
      old = %{stable: 1, important_change: [1]}
      new =  %{stable: 1, important_change: []}

      assert_same_map(new, old, except: [important_change: &Enum.empty?/1])

      assertion_fails(
        "Field `:important_change` has the wrong value",
        [left: [1]],
        fn -> 
          assert_same_map(old, old, except: [important_change: &Enum.empty?/1])
        end)
    end

    test "'except' fields must be present" do
      new = old = %__MODULE__{name: 1}
      assertion_fails(
        ~r/Test error: there is no key `:extra` in FlowAssertions.Map.*Test/,
        fn -> 
          assert_same_map(new, old, except: [extra: 33])
        end)
    end
  end

  test "combinations of arguments" do
    old = %{stable: 1, important_change: [1], who_cares: 1}
    new =  %{stable: 1, important_change: [], who_cares: 2}
    
    assert_same_map(new, old,
      except: [important_change: &Enum.empty?/1],
      ignoring: [:who_cares])
  end

  defmodule S do 
    defstruct a: 5, b: 3
  end

  defmodule R do 
    defstruct a: 5, b: 3
  end

  describe "structures are compared to structures" do
    test "original structures" do
      assert_same_map(%S{}, %S{})

      assertion_fails(
        Messages.stock_equality,
        fn -> 
          assert_same_map(%S{}, %R{})
        end)
    end

    test "result of ignoring" do
      assert_same_map(%S{a: 3}, %S{a: 4}, ignoring: [:a])

      assertion_fails(
        Messages.stock_equality,
        fn -> 
          assert_same_map(%S{a: 3}, %R{a: 4}, ignoring: [:a])
        end)
    end

    test "result of `comparing`" do
      assert_same_map(%S{a: 3}, %S{a: 4}, comparing: [:b])
      
      assertion_fails(
        Messages.stock_equality,
        fn -> 
          assert_same_map(%S{}, %R{}, ignoring: [:a])
        end)
    end
  end
end
  
