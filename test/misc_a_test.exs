defmodule FlowAssertions.MiscATest do
  use FlowAssertions.Case

  test "assert_ok" do
    a = assertion_runners_for(&assert_ok/1) |> left_is_actual

    :ok                  |> a.pass.()
    {:ok, :not_examined} |> a.pass.()

    :error               |> a.fail.(Messages.not_ok)
  end

  test "ok_content" do
    a = content_runners_for(&ok_content/1) |> left_is_actual
    
    {:ok, "content"}    |> a.pass.("content")
    :ok                 |> a.fail.(Messages.not_ok_tuple)
    {:error, "content"} |> a.fail.(Messages.not_ok_tuple)
  end

  test "ok_content/2 with struct name argument" do
    a = content_runners_for(&(ok_content &1, Date))
    date = ~D[2001-01-01]
    datetime = ~N[2001-01-01 01:01:01.000]
    
    {:ok, date}     |> a.pass.(date)
    {:ok, datetime} |> a.fail.(Messages.wrong_struct_name(NaiveDateTime, Date))
                    |> a.plus.(left: datetime)
    

    # As before
    :ok                 |> a.fail.(Messages.not_ok_tuple)
    {:error, "content"} |> a.fail.(Messages.not_ok_tuple)
  end

  test "assert_error" do
    a = assertion_runners_for(&assert_error/1) |> left_is_actual

    :error                     |> a.pass.()
    {:error, :not_examined}    |> a.pass.()

    {:ok, 5}                   |> a.fail.(Messages.not_error)
  end

  test "error_content" do
    assert error_content({:error, "content"}) == "content"

    msg = Messages.not_error_tuple
    (&error_content/1)
    |> assertion_fails_for(:error, msg)
    |> assertion_fails_for({:ok, "content"}, msg)
  end

  test "assert_error2" do
    run = fn actual -> assert_error2(actual, :expected_error_type) end
    a = assertion_runners_for(run) |> left_is_actual
    
    wrong_shape_message = Messages.not_error_3tuple(:expected_error_type)
    wrong_subtype_message =
      Messages.bad_error_3tuple_subtype(:wrong_type, :expected_error_type)

    {:error, :expected_error_type, "irrelevant"} |> a.pass.()
    {:error, :wrong_type,          "irrelevant"} |> a.fail.(wrong_subtype_message)

    :error                                       |> a.fail.(wrong_shape_message)
    {:error, "content"}                          |> a.fail.(wrong_shape_message)
    "anything else"                              |> a.fail.(wrong_shape_message)
  end

  test "error2_content" do
    assert error2_content({:error, :right, "content"}, :right) == "content"

    (&(error2_content(&1, :expected_error_type)))
    |> assertion_fails_for({:error, :bad_subtype, "content"},
         Messages.bad_error_3tuple_subtype(:bad_subtype, :expected_error_type))
  end

  test "assert_equal" do
    a = assertion_runners_for(&assert_equal/2)

    ["value", "value"] |> a.pass.()
    ["value", "     "] |> a.fail.("Assertion with === failed")
                       |> a.plus.(left: "value", right: "     ")

    # Clearer demonstration that `===` is used:
    [1, 1.0]           |> a.fail.("Assertion with === failed")
                       |> a.plus.(left: 1,       right: 1.0)
  end


  test "assert_equals is same as assert_equal" do
    a = assertion_runners_for(&assert_equals/2)

    ["value", "value"] |> a.pass.()
    ["value", "     "] |> a.fail.("Assertion with === failed")
                       |> a.plus.(left: "value", right: "     ")
  end
  

  # ----------------------------------------------------------------------------
  
  defstruct a: 1, b: 2
  
  describe "assert_shape" do
    test "structs" do

      pinned_value = 3
      actual = %__MODULE__{a: pinned_value}

      actual
      |> assert_shape( %{})
      |> assert_shape(%__MODULE__{})
      |> assert_shape(%__MODULE__{a: 3})
      |> assert_shape(%__MODULE__{a: ^pinned_value})

      assertion_fails(
        Messages.no_match,
        # Note that there's no good way to print the failing pattern.
        [left: actual, right: AssertionError.no_value],
        fn -> 
          assert_shape(actual, %Date{})
        end)

      assertion_fails(
        Messages.no_match,
        [left: actual],
        fn -> 
          assert_shape(actual, %__MODULE__{a: 88})
        end)
    end

    test "shapes with arrays" do
      assert_shape([1], [_])
      assert_shape([1], [_ | _])
      assert_shape([1, 2],  [_ | _])
      assertion_fails(
        Messages.no_match,
        [left: [1]],
        fn ->
          assert_shape(no_op([1]), [])
        end)

      assertion_fails(
        Messages.no_match,
        [left: [1]],
        fn -> assert_shape(no_op([1]), [2]) end)

      assertion_fails(
        Messages.no_match,
        [left: [1, 2]],
        fn -> assert_shape(no_op([1, 2]), [_,  _ , _]) end)
    end
  end

  # This prevents impossible matches from being flagged at compile time.
  defp no_op(list), do: list

  describe "being good enough" do
    test "good_enough? as a predicate" do
      assert good_enough?(1, &(&1 == 1))
      refute good_enough?(2, &(&1 == 1))
    end

    test "the predicate can return truthy/falsey values" do
      assert good_enough?(1, fn _ -> 5 end)
      refute good_enough?(1, fn _ -> nil end)
    end

    test "but two functions are still compared" do
      a = &Map.from_struct/1
      b = &Map.from_struct/1
      assert good_enough?(a, b)
    end
    
    test "fallback to ==" do
      assert good_enough?(1.0, 1)
      refute good_enough?(1, 2)
    end

    test "comparing a string to a regular expression" do
      assert good_enough?("string", ~r/s.r..g/)
      assert good_enough?("string", ~r/s.r/)
      refute good_enough?("string", ~r/s.t/)
    end

    test "other comparisons to regular expressions" do
      refute good_enough?(~r/s.r..g/, "string")
      assert good_enough?(~r/s.r/, ~r/s.r/)
    end
  end

  describe "assert_good_enough" do
    test "success cases" do
      assert assert_good_enough(1, &(&1 == 1)) == 1
      assert assert_good_enough(1.0, 1) == 1.0
      assert assert_good_enough("string", ~r/s.r..g/) == "string"
      assert assert_good_enough("string", ~r/s.r/) == "string"
    end

    def foo(1, 2), do: false

    test "failing predicate has its own kind of output" do
      (fn arg -> assert_good_enough(arg, &is_map/1) end)
      |> assertion_fails_for([1], Messages.failed_predicate(&is_map/1))
    end

    test "... unless both arguments are predicates" do
      assertion_fails("Assertion with == failed",
        [left: &Map.take/2, right: &Map.drop/2], 
        fn -> 
          assert_good_enough(&Map.take/2, &Map.drop/2)
        end)
    end

    test "failing regex has usual equality output" do
      assertion_fails(Messages.no_regex_match,
        [left: "string", right: ~r/sr/],
        fn -> 
          assert_good_enough("string", ~r/sr/)
        end)
    end

    test "... even if both sides are regexps" do
      assertion_fails(Messages.stock_equality,
        [left: ~r/DIFF/, right: ~r/sr/], 
        fn -> 
          assert_good_enough(~r/DIFF/, ~r/sr/)
        end)
    end

    test "fallback has usual equality output" do
      assertion_fails(Messages.stock_equality,
        [left: 4, right: 5],
        fn -> 
          assert_good_enough(4, 5)
        end)
    end

    test "checkers can succeed just like any predicate" do
      "bac"
      |> assert_good_enough(has_slice("a"))
    end

    test "checkers can fail" do
      assertion_fails(Messages.failed_checker(~s[has_slice("bac")]),
        [left: "a"],
        fn -> 
          assert_good_enough("a", has_slice("bac"))
        end)
    end
  end

  test "ok_id" do
    assert ok_id({:ok, %{id: 3}}) == 3
    assertion_fails(
      Messages.not_ok_tuple,
      [left: {:error, %{no: :id}}],
      fn ->
        ok_id({:error, %{no: :id}})
      end)
  end
end
