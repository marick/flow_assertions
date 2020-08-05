defmodule FlowAssertions.MapATest do
  use ExUnit.Case, async: true
  use FlowAssertions

#  import FlowAssertions.{Map, Assertion}

  # defstruct name: nil # Used for typo testing

  # @under_test %{field1: 1, field2: 2, list: [1, 2], empty: []}

  # describe "`assert_fields` with keyword lists" do
  #   test "assertion failure" do
  #     assertion_fails_with_diagnostic(
  #       "Field `:missing_field` is missing",
  #       fn -> 
  #         assert_fields(@under_test, field1: 1,  missing_field: 5)
  #       end)
  #   end

  #   test "how a bad value is reported" do
  #     assertion_fails_with_diagnostic(
  #       ["`:field2` has the wrong value",
  #        "actual:   2",
  #        "expected: 3838"],
  #       fn -> 
  #         assert_fields(@under_test, field1: 1,  field2: 3838)
  #       end)
  #   end
        
  #   test "no failure returns value being tested" do 
  #     result = assert_fields(@under_test, field1: 1)
  #     assert @under_test == result
  #   end

  #   test "note that the field must actually be present" do
  #     # We don't use Map.get with a default.
  #     assertion_fails_with_diagnostic(
  #       "Field `:missing_field` is missing",
  #       fn ->
  #         assert_fields(@under_test, missing_field: nil)
  #       end)
  #   end

  #   test "can check a field against a predicate" do
  #     # pass
  #     assert @under_test == assert_fields(@under_test, empty: &Enum.empty?/1)

  #     # fail
  #     assert_raise ExUnit.AssertionError, fn ->
  #       assert_fields(@under_test, list: &Enum.empty?/1)
  #     end
  #   end

  #   test "how bad predicate values are printed" do
  #     assertion_fails_with_diagnostic(
  #       ":list => [1, 2] fails predicate &Enum.empty?/1",
  #       fn ->
  #         assert_fields(@under_test, list: &Enum.empty?/1)
  #       end)
  #   end
  # end

  # describe "`assert_fields` with just a list of fields" do
  #   test "how failure is reported" do
  #     assertion_fails_with_diagnostic(
  #       "Field `:missing_field` is missing",
  #       fn -> 
  #         assert_fields(@under_test, [:field1, :missing_field])
  #     end)
  #   end

  #   test "no failure returns value being tested" do 
  #     result = assert_fields(@under_test, [:field1])
  #     assert @under_test == result
  #   end

  #   test "`nil` and `false` are valid values." do
  #     input = %{nil_field: nil, false_field: false}
  #     assert_fields(input, [:nil_field, :false_field])
  #   end
  # end

  # describe "`assert_field`" do
  #   test "usefulness for the grammar pedant" do 
  #     assert_field(@under_test, field1: 1)
  #   end

  #   test "you can use a singleton value to test field presence" do
  #     assertion_fails_with_diagnostic(
  #       "Field `:missing_field` is missing",
  #       fn -> 
  #         assert_field(@under_test, :missing_field)
  #       end)
  #   end
  # end

  # describe "typo protection" do
  #   test "... is possible in a struct" do
  #     struct = %__MODULE__{name: "hello"}

  #     assertion_fails_with_diagnostic(
  #       "Test error: there is no key `:typo` in FlowAssertions.MapTest",
  #       fn ->
  #         assert_field(struct, :typo)
  #       end)

  #     assertion_fails_with_diagnostic(
  #       "Test error: there is no key `:typo` in FlowAssertions.MapTest",
  #       fn ->
  #         assert_field(struct, typo: 5)
  #       end)

  #     # It doesn't spuriously fail.
  #     # (Everywhere else in this file, we use maps.)
  #     assert_field(struct, :name)

  #     # It doesn't fail on maps *for this reason*.
  #     assertion_fails_with_diagnostic(
  #       "Field `:typo` is missing",
  #       fn -> 
  #         assert_field(%{name: 3}, typo: 3)
  #       end)
  #   end
  # end

  # describe "`assert_copy`" do
  #   test "can ignore fields" do
  #     old = %{stable: 1, field2: 22222}
  #     new =  %{stable: 1, field2: 2}

  #     # Here, for reference is what plain equality does:
  #     assert_raise(ExUnit.AssertionError, fn -> 
  #       assert new == old
  #     end)
  #     |> assert_fields(left: new,
  #                      right: old,
  #                      message: "Assertion with == failed")

  #     # No error
  #     assert_copy(new, old, ignoring: [:field2])

  #     # assert_copy fails the same way `assert ==` does
  #     # except note that it doesn't mention `ignoring` fields
  #     assert_raise(ExUnit.AssertionError, fn -> 
  #       assert_copy(new, old, ignoring: [:stable])
  #     end)
  #     |> assert_fields(left: %{field2: 2},
  #                      right: %{field2: 22222},
  #                      message: "Assertion with == failed")
  #   end

  #   test "can do `assert_fields` comparisons" do
  #     old = %{stable: 1, important_change: 22222}
  #     new =  %{stable: 1, important_change: 2}

  #     assert_copy(new, old, except: [important_change: 2])

  #     assert_raise(ExUnit.AssertionError, fn -> 
  #       assert_copy(new, old, except: [important_change: 33])
  #     end)
  #     |> assert_field(
  #          message: "`:important_change` has the wrong value.\nactual:   2\nexpected: 33\n")
  #   end
    
  #   test "`:except` assertions can include predicates" do
  #     old = %{stable: 1, important_change: [1]}
  #     new =  %{stable: 1, important_change: []}

  #     assert_copy(new, old, except: [important_change: &Enum.empty?/1])

  #     assert_raise(ExUnit.AssertionError, fn -> 
  #       assert_copy(old, old, except: [important_change: &Enum.empty?/1])
  #     end)
  #     |> assert_field(
  #         message:  ":important_change => [1] fails predicate &Enum.empty?/1"
  #     )
  #   end

  #   test "combinations of arguments" do
  #     old = %{stable: 1, important_change: [1], who_cares: 1}
  #     new =  %{stable: 1, important_change: [], who_cares: 2}

  #     assert_copy(new, old,
  #       except: [important_change: &Enum.empty?/1],
  #       ignoring: [:who_cares])
  #   end

  #   test "'ignored' fields must be present in new *struct*" do
  #     new = old = %__MODULE__{name: 1}
  #     assertion_fails_with_diagnostic(
  #       "Test error: there is no key `:extra` in FlowAssertions.MapTest",
  #       fn -> 
  #         assert_copy(new, old, ignoring: [:extra])
  #       end)
  #   end
    
  #   test "'except' fields must be present" do
  #     new = old = %__MODULE__{name: 1}
  #     assertion_fails_with_diagnostic(
  #       "Test error: there is no key `:extra` in FlowAssertions.MapTest",
  #       fn -> 
  #         assert_copy(new, old, except: [extra: 33])
  #       end)
  #   end
  # end

  # test "partial copy comparison" do
  #   old = %{stable: 1,  change: [1]}
  #   new =  %{stable: 1, change: []}

  #   assert_partial_copy(new, old, [:stable])

  #   assertion_fails_with_diagnostic(
  #     ["Assertion with == failed"],
  #     fn -> 
  #       assert_partial_copy(new, old, [:stable, :change])
  #     end)
  # end
  
  # describe "shape comparison" do
  #   test "map-like" do
  #     assert %PermissionList{}.view_reservations == true # default
      
  #     (fresh = %{p: %PermissionList{}})
  #     |> assert_field_shape(:p, %{})
  #     |> assert_field_shape(:p, %PermissionList{})
  #     |> assert_field_shape(:p, %PermissionList{view_reservations: true})
      
  #     assertion_fails_with_diagnostic(
  #       ["The value doesn't match the given pattern"],
  #       fn -> 
  #         assert_field_shape(fresh, :p, %User{})
  #       end)
      
  #     assertion_fails_with_diagnostic(
  #       ["The value doesn't match the given pattern"],
  #       fn -> 
  #         assert_field_shape(fresh, :p, %PermissionList{view_reservations: false})
  #       end)
  #   end
    
  #   # This needs to be outside the test to keep compiler from knowing that
  #   # a match is impossible. It has to be outside the describe because
  #   # "cannot invoke defp/2 inside function/macro"
  #   defp singleton(), do: %{p: [1]}
    
  #   test "shapes with arrays" do
  #     singleton = singleton()
  #     assert_field_shape(singleton, :p, [_])
  #     assert_field_shape(singleton, :p, [_ | _])
  #     assertion_fails_with_diagnostic(
  #       ["The value doesn't match the given pattern"],
  #       fn -> assert_field_shape(singleton, :p, []) end)
      
  #     assertion_fails_with_diagnostic(
  #       ["The value doesn't match the given pattern"],
  #       fn -> assert_field_shape(singleton, :p, [2]) end)
      
  #     assertion_fails_with_diagnostic(
  #       ["The value doesn't match the given pattern"],
  #       fn -> assert_field_shape(singleton, :p, [_,  _ | _]) end)
  #   end
  # end

  # # ----------------------------------------------------------------------------
  # test "assert_nothing and friends" do
  #   data = %{nothing: :nothing, something: "something"}
  #   assert assert_nothing(data, :nothing) == data
  #   assert refute_nothing(data, :something) == data
    
  #   assertion_fails_with_diagnostic(
  #     "Expected key `:something` to be `:nothing`",
  #     fn -> 
  #       assert_nothing(data, :something)
  #     end)
    
  #   assertion_fails_with_diagnostic(
  #     "Key `:nothing` unexpectedly has value `:nothing`",
  #     fn -> 
  #       refute_nothing(data, :nothing)
  #     end)
    
  # end
end

