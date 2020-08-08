defmodule FlowAssertions.MapAAssertFieldsTest do
  use ExUnit.Case, async: true
  use FlowAssertions

  @map %{field1: 1, field2: 2, list: [1, 2], empty: [], name: "cohort_fred"}

  describe "`assert_fields` with keyword lists" do
    test "missing field" do
      checks = [field1: 1,  missing_field: 5]
      assertion_fails("Field `:missing_field` is missing",
        [left: @map, right: checks],
        fn -> 
          assert_fields(@map, checks)
        end)
    end

    test "how a bad value is reported" do
      assertion_fails("Field `:field2` has the wrong value",
        [left: 2, right: 3838],
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
    test "can check a field against a predicate" do
      assert assert_fields(@map, empty: &Enum.empty?/1) == @map

      # A little annoying that the predicate isn't shown in the `:right`.
      assertion_fails("Field `:list` has the wrong value",
        [left: @map.list],
        fn ->
          assert_fields(@map, list: &Enum.empty?/1)
        end)
    end

    test "can check a field against a regular expression" do
      assert assert_fields(@map, name: ~r/cohort/) == @map

      assertion_fails("Field `:name` has the wrong value",
        [left: @map.name, right: ~r/_cohort/],
        fn ->
          assert_fields(@map, name: ~r/_cohort/)
        end)
    end
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

