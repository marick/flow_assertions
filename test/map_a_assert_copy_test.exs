defmodule FlowAssertions.MapAAssertCopyTest do
  use ExUnit.Case, async: true
  use FlowAssertions
  alias FlowAssertions.Messages

  defstruct name: nil # Used for typo testing

  describe "`assert_same_map`" do
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

    @tag :skip
    test "can do `assert_fields` comparisons" do
      old = %{stable: 1, important_change: 22222}
      new =  %{stable: 1, important_change: 2}

      assert_same_map(new, old, except: [important_change: 2])

      assert_raise(ExUnit.AssertionError, fn -> 
        assert_same_map(new, old, except: [important_change: 33])
      end)
      |> assert_field(
           message: "`Field :important_change` has the wrong value.\nactual:   2\nexpected: 33\n")
    end

    @tag :skip
    test "`:except` assertions can include predicates" do
      old = %{stable: 1, important_change: [1]}
      new =  %{stable: 1, important_change: []}

      assert_same_map(new, old, except: [important_change: &Enum.empty?/1])

      assert_raise(ExUnit.AssertionError, fn -> 
        assert_same_map(old, old, except: [important_change: &Enum.empty?/1])
      end)
      |> assert_field(
          message:  ":important_change => [1] fails predicate &Enum.empty?/1"
      )
    end

    test "combinations of arguments" do
      old = %{stable: 1, important_change: [1], who_cares: 1}
      new =  %{stable: 1, important_change: [], who_cares: 2}

      assert_same_map(new, old,
        except: [important_change: &Enum.empty?/1],
        ignoring: [:who_cares])
    end

    @tag :skip
    test "'ignored' fields must be present in new *struct*" do
      new = old = %__MODULE__{name: 1}
      assertion_fails_with_diagnostic(
        "Test error: there is no key `:extra` in FlowAssertions.MapTest",
        fn -> 
          assert_same_map(new, old, ignoring: [:extra])
        end)
    end

    @tag :skip
    test "'except' fields must be present" do
      new = old = %__MODULE__{name: 1}
      assertion_fails_with_diagnostic(
        "Test error: there is no key `:extra` in FlowAssertions.MapTest",
        fn -> 
          assert_same_map(new, old, except: [extra: 33])
        end)
    end
  end
end  
