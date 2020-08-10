defmodule MyApp.Custom do 
  use FlowAssertions.NoValueA, no_value: :_nothing
end

defmodule FlowAssertions.NoValueCustomTest do
  use FlowAssertions.Case
  import MyApp.Custom
  

  # ----------------------------------------------------------------------------
  test "assert_no_value and friends" do
    data = %{nothing_field: :_nothing, something_field: "something"}
    assert assert_no_value(data, :nothing_field) == data
    assert refute_no_value(data, :something_field) == data

    assertion_fails(
      Messages.not_no_value(:something_field, :_nothing),
      [left: "something"],
      fn -> 
        assert_no_value(data, :something_field)
      end)
    
    assertion_fails(
      Messages.not_value(:nothing_field),
      [left: :_nothing],
      fn -> 
        refute_no_value(data, :nothing_field)
      end)
  end
end

