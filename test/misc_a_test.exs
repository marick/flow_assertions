defmodule FlowAssertions.MiscATest do
  use ExUnit.Case, async: true
  use FlowAssertions

  test "assert_ok" do
    :ok = assert_ok(:ok)
    {:ok, :not_examined} = assert_ok({:ok, :not_examined})

    assert_raise(ExUnit.AssertionError, fn ->
      assert_ok(:error)
    end)
  end

  test "ok_content" do
    assert "content" == ok_content({:ok, "content"})
    assert_raise(ExUnit.AssertionError, fn ->
      ok_content(:ok)
    end)
    assert_raise(ExUnit.AssertionError, fn ->
      ok_content({:error, "content"})
    end)
  end

  test "assert_error" do
    :error = assert_error(:error)
    {:error, :not_examined} = assert_error({:error, :not_examined})
    assert_raise(ExUnit.AssertionError, fn ->
      assert_error({:ok, 5})
    end)
  end

  test "error_content" do
    assert "content" == error_content({:error, "content"})
    assert_raise(ExUnit.AssertionError, fn ->
      error_content(:error)
    end)
    assert_raise(ExUnit.AssertionError, fn ->
      error_content({:ok, "content"})
    end)
  end

  test "error2_content" do
    assert "content" == error2_content({:error, :right, "content"}, :right)
    
    assert_raise(ExUnit.AssertionError, fn ->
      error2_content({:error, "content"}, :ignored)
    end)
    assert_raise(ExUnit.AssertionError, fn ->
      error2_content({:error, :wrong, "content"}, :right)
    end)

    assert_raise(ExUnit.AssertionError, fn ->
      error2_content(:error, :ignored)
    end)
    assert_raise(ExUnit.AssertionError, fn ->
      error2_content({:ok, "content"}, :ignored)
    end)
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

