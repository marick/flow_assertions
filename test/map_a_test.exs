defmodule FlowAssertions.MapATest do
  use ExUnit.Case, async: true
  use FlowAssertions






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

