defmodule FlowAssertions.EnumATest do
  use FlowAssertions.Case
  import FlowAssertions.Define.Tabular

  @moduledoc """
  Assertions for values that satisfy the `Enum` protocol.
  """

  describe "assert_singleton" do
    setup do
      [a: assertion_runners_for(&assert_singleton/1) |> left_is_actual]
    end
    
    test "typical use: lists", %{a: a} do
      [1   ] |> a.pass.()
      [    ] |> a.fail.(Messages.expected_1_element)
      [1, 2] |> a.fail.(Messages.expected_1_element)
    end

    test "any Enum can be used", %{a: a} do
      %{a: 1}       |> a.pass.()
      %{    }       |> a.fail.(Messages.expected_1_element)
      %{a: 1, b: 2} |> a.fail.(Messages.expected_1_element)
    end
  end

  describe "singleton_content" do 
    setup do
      [a: content_runners_for(&singleton_content/1) |> left_is_actual]
    end
    
    test "typical use: lists", %{a: a} do
      [1   ] |> a.pass.(1)
      [    ] |> a.fail.(Messages.expected_1_element)
      [1, 2] |> a.fail.(Messages.expected_1_element)
    end

    test "any Enum can be used", %{a: a} do
      %{a: 1}       |> a.pass.({:a, 1})
      %{    }       |> a.fail.(Messages.expected_1_element)
      %{a: 1, b: 2} |> a.fail.(Messages.expected_1_element)
    end

    test "non-Enum case fails", %{a: a} do
      "string" |> a.fail.(Messages.not_enumerable)
    end
  end

  test "singleton_content/2 with struct name argument" do
    a = content_runners_for(&(singleton_content &1, Date))
    date = ~D[2001-01-01]
    datetime = ~N[2001-01-01 01:01:01.000]
    
    [date]     |> a.pass.(date)
    [datetime] |> a.fail.(Messages.wrong_struct_name(NaiveDateTime, Date))
               |> a.plus.(left: datetime)

    # As before
    [    ] |> a.fail.(Messages.expected_1_element)
    [1, 2] |> a.fail.(Messages.expected_1_element)
  end
  

  test "assert_enumerable" do
    a = assertion_runners_for(&assert_enumerable/1) |> left_is_actual

    [] |> a.pass.()
    1  |> a.fail.(Messages.not_enumerable)
  end

  test "assert_empty" do
    a = assertion_runners_for(&assert_empty/1) |> left_is_actual

     [    ]   |> a.pass.()
     [1   ]  |> a.fail.(Messages.expected_no_element)
    %{    }  |> a.pass.()
    %{a: 2}  |> a.fail.(Messages.expected_no_element)
  end
end
  
