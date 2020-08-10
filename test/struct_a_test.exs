defmodule FlowAssertions.StructATest do
  use FlowAssertions.Case

  test "assert_struct_named" do
    date = ~D{2012-12-12}
    assert assert_struct_named(date, Date) == date

    assertion_fails_with_diagnostic(
      "Expected a `Date` but got a `NaiveDateTime`",
      fn -> assert_struct_named(~N{2012-12-12 01:02:03.000}, Date) end)

    assertion_fails_with_diagnostic(
      "Expected a `Date` but got a plain Map",
      fn -> assert_struct_named(%{}, Date) end)
    
    assertion_fails_with_diagnostic(
      ["Expected a `Date` but got `5`"],
      fn -> assert_struct_named(5, Date) end)
  end
end
  
