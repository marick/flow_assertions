defmodule FlowAssertions.StructATest do
  use FlowAssertions.Case

  test "assert_struct_named" do
    date = ~D{2012-12-12}
    assert assert_struct_named(date, Date) == date
    
    naive = ~N{2012-12-12 01:02:03.000}
    assertion_fails(
      Messages.wrong_struct_name(NaiveDateTime, Date),
      [left: naive],
      fn ->
        assert_struct_named(naive, Date)
      end)

    assertion_fails(
      Messages.map_not_struct(Date),
      [left: %{}],
      fn -> assert_struct_named(%{}, Date) end)

    assertion_fails(
      Messages.very_wrong_struct(Date),
      [left: 5],
      fn -> assert_struct_named(5, Date) end)
  end
end
  
