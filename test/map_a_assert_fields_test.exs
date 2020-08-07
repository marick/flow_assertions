defmodule FlowAssertions.MapAAssertFieldsTest do
  use ExUnit.Case, async: true
  use FlowAssertions

  @map %{field1: 1, field2: 2, list: [1, 2], empty: []}

  describe "`assert_fields` with keyword lists" do
    test "missing field" do
      assertion_fails_with_diagnostic(
        "Field `:missing_field` is missing",
        fn -> 
          assert_fields(@map, field1: 1,  missing_field: 5)
        end)
    end

    @tag :skip
    test "how a bad value is reported" do
      assertion_fails_with_diagnostic(
        ["`:field2` has the wrong value",
         "actual:   2",
         "expected: 3838"],
        fn -> 
          assert_fields(@map, field1: 1,  field2: 3838)
        end)
    end
        
    test "no failure returns value being tested" do 
      result = assert_fields(@map, field1: 1)
      assert @map == result
    end

  end


  describe "follows rules for `MiscA.assert_good_enough`" do
    @tag :skip
    test "can check a field against a predicate" do
      # pass
      assert @map == assert_fields(@map, empty: &Enum.empty?/1)

      # fail
      assert_raise ExUnit.AssertionError, fn ->
        assert_fields(@map, list: &Enum.empty?/1)
      end
    end

    @tag :skip
    test "how bad predicate values are printed" do
      assertion_fails_with_diagnostic(
        ":list => [1, 2] fails predicate &Enum.empty?/1",
        fn ->
          assert_fields(@map, list: &Enum.empty?/1)
        end)
    end
    
     #    assert_fields(some_map, [name: ~r/_cohort/])
  end


  describe "`assert_fields` with just a list of fields" do
    test "how failure is reported" do
      assertion_fails_with_diagnostic(
        "Field `:missing_field` is missing",
        fn -> 
          assert_fields(@map, [:field1, :missing_field])
      end)
    end

    test "no failure returns value being tested" do 
      result = assert_fields(@map, [:field1])
      assert @map == result
    end

    test "`nil` and `false` are valid values." do
      input = %{nil_field: nil, false_field: false}
      assert_fields(input, [:nil_field, :false_field])
    end
  end

  @tag :skip
  test "a mixture of value and existence checks" do
    assert assert_fields(@map, [field1: 1] ++ [:field2]) == @map

    assertion_fails_with_diagnostic(
      ["`:field1` has the wrong value"],
      fn -> 
        assert_fields(@map, [{:field1, 33}, :field2])
      end)
    
    assertion_fails_with_diagnostic(
      "Field `:missing` is missing",
      fn -> 
        assert_fields(@map, [{:field1, 1}, :missing])
      end)
  end
end

