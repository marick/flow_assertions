defmodule FlowAssertions.MiscATest do
  use ExUnit.Case, async: true
  use FlowAssertions
  alias FlowAssertions.Messages

  test "assert_ok" do
    assert assert_ok(:ok) == :ok
    assert assert_ok({:ok, :not_examined}) == {:ok, :not_examined}

    (&assert_ok &1)
    |> assertion_fails_for(:error, Messages.not_ok)
  end


  test "ok_content" do
    assert ok_content({:ok, "content"}) == "content"
    msg = Messages.not_ok_tuple

    (&ok_content/1)
    |> assertion_fails_for(:ok, msg)
    |> assertion_fails_for({:error, "content"}, msg)
  end

  test "assert_error" do
    assert assert_error(:error) == :error
    assert assert_error({:error, :not_examined}) == {:error, :not_examined}

    (&assert_error/1)
    |> assertion_fails_for({:ok, 5}, Messages.not_error)
  end

  test "error_content" do
    assert error_content({:error, "content"}) == "content"

    msg = Messages.not_error_tuple
    (&error_content/1)
    |> assertion_fails_for(:error, msg)
    |> assertion_fails_for({:ok, "content"}, msg)
  end

  test "assert_error_2" do
    valid = {:error, :expected_error_type, "content"}
    assert assert_error2(valid, :expected_error_type) == valid

    bad_form_msg = Messages.not_error_3tuple(:expected_error_type)

    (&(assert_error2(&1, :expected_error_type)))
    |> assertion_fails_for(:error, bad_form_msg)
    |> assertion_fails_for({:error, "content"}, bad_form_msg)
    |> assertion_fails_for("anything else", bad_form_msg)

    |> assertion_fails_for({:error, :bad_subtype, "content"},
         Messages.bad_error_3tuple_subtype(:bad_subtype, :expected_error_type))
  end

  test "error2_content" do
    assert error2_content({:error, :right, "content"}, :right) == "content"

    (&(error2_content(&1, :expected_error_type)))
    |> assertion_fails_for({:error, :bad_subtype, "content"},
         Messages.bad_error_3tuple_subtype(:bad_subtype, :expected_error_type))
  end

  describe "assert_equal" do 
    test "basics" do
      assert "value" == assert_equal("value", "value")
      assert "value" == assert_equals("value", "value")
      
      assert_raise(ExUnit.AssertionError, fn ->
        assert_equal(1, 2)
      end)
      
      assert_raise(ExUnit.AssertionError, fn ->
        assert_equals(1, 2)
      end)
    end
    
    test "uses `===`" do
      assert_raise(ExUnit.AssertionError, fn ->
        assert_equal(1, 1.0)
      end)
    end
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

      assertion_fails_with_diagnostic(
        ["The value doesn't match the given pattern"],
        fn -> 
          assert_shape(actual, %Date{})
        end)
      
      assertion_fails_with_diagnostic(
        ["The value doesn't match the given pattern"],
        fn -> 
          assert_shape(actual, %__MODULE__{a: 88})
        end)
    end

    test "shapes with arrays" do
      assert_shape([1], [_])
      assert_shape([1], [_ | _])
      assert_shape([1, 2],  [_ | _])
      assertion_fails_with_diagnostic(
        ["The value doesn't match the given pattern"],
        fn -> assert_shape(no_op([1]), []) end)

      assertion_fails_with_diagnostic(
        ["The value doesn't match the given pattern"],
        fn -> assert_shape(no_op([1]), [2]) end)

      assertion_fails_with_diagnostic(
        ["The value doesn't match the given pattern"],
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

    @tag :skip
    test "failing predicate has its own kind of output" do
      assertion_fails_with_diagnostic(
        "[1] fails predicate",
        fn -> assert_good_enough([1], &is_map/1) end)
    end

    test "... unless both arguments are predicates" do
      exception = assert_raise(ExUnit.AssertionError, fn ->
        assert_good_enough(&Map.take/2, &Map.drop/2)
      end)

      assert exception.message =~ "Assertion with == failed"
      assert exception.left == &Map.take/2
      assert exception.right == &Map.drop/2
    end

    test "failing regex has usual equality output" do
      exception = assert_raise(ExUnit.AssertionError, fn ->
        assert_good_enough("string", ~r/sr/)
      end)

      assert exception.message =~ "Assertion with == failed"
      assert exception.left == "string"
      assert exception.right == ~r/sr/
    end


    test "... even if both sides are regexps" do
      exception = assert_raise(ExUnit.AssertionError, fn ->
        assert_good_enough(~r/DIFF/, ~r/sr/)
      end)

      assert exception.message =~ "Assertion with == failed"
      assert exception.left == ~r/DIFF/
      assert exception.right == ~r/sr/
    end


    test "fallback has usual equality output" do
      exception = assert_raise(ExUnit.AssertionError, fn ->
        assert_good_enough(4, 5)
      end)

      assert exception.message =~ "Assertion with == failed"
      assert exception.left == 4
      assert exception.right == 5
    end
  end
  

  

  # test "ok_id" do
  #   assert 3 == ok_id({:ok, %{id: 3}})
  #   assert_raise(ExUnit.AssertionError, fn ->
  #     ok_id({:error, %{no: :id}})
  #   end)
  #   assert_raise(ExUnit.AssertionError, fn ->
  #     ok_id(:ok)
  #   end)
  #   assert_raise(ExUnit.AssertionError, fn ->
  #     ok_id({:error, %{id: :irrelevant}})
  #   end)
  # end


end

