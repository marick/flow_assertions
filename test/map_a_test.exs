defmodule FlowAssertions.MapATest do
  use FlowAssertions.Case

  defmodule Permissions do
    defstruct view_reservations: true, other: false
  end

  describe "shape comparison" do
    test "map-like" do
      assert %Permissions{}.view_reservations == true # default
      
      fresh = %{p: %Permissions{}}

      fresh
      |> assert_field_shape(:p, %{})
      |> assert_field_shape(:p, %Permissions{})
      |> assert_field_shape(:p, %Permissions{view_reservations: true})

      assertion_fails(
        Messages.no_field_match(:p),
        fn -> 
          assert_field_shape(fresh, :p, %Permissions{view_reservations: false})
        end)
    end
    
    # This needs to be outside the test to keep compiler from knowing that
    # a match is impossible. It has to be outside the describe because
    # "cannot invoke defp/2 inside function/macro"
    defp singleton(), do: %{p: [1]}
    
    test "shapes with arrays" do
      singleton = singleton()
      assert_field_shape(singleton, :p, [_])
      assert_field_shape(singleton, :p, [_ | _])
      assertion_fails(
        Messages.no_field_match(:p),
        fn -> assert_field_shape(singleton, :p, []) end)
      
      assertion_fails(
        Messages.no_field_match(:p),
        fn -> assert_field_shape(singleton, :p, [2]) end)
      
      assertion_fails(
        Messages.no_field_match(:p),
        fn -> assert_field_shape(singleton, :p, [_,  _ | _]) end)
    end
  end

  describe "refute_fields" do

    test "basic" do 
      assert refute_fields(%{a: 1}, [:b]) == %{a: 1}
      
      assertion_fails(
        Messages.field_wrongly_present("a"),
        [left: %{"a" => [], "b" => 2}],
        fn -> 
          refute_fields(%{"a" => [], "b" => 2}, ["a", "b"])
        end)
    end

    test "variants" do
      map = %{a: 1}

      run = fn f ->
        assertion_fails(
          Messages.field_wrongly_present(:a),
          [left: map],
          f)
      end

      run.(fn -> refute_field(map, :a) end)
      # tolerate typos
      run.(fn -> refute_field(map, [:a]) end)
      run.(fn -> refute_fields(map, :a) end)
    end
  end

  test "with_singleton_content" do
    assert with_singleton_content(%{a: [1]}, :a) == 1

    assertion_fails(
      Messages.expected_1_element_field("a"),
      [left: []],
      fn -> 
        with_singleton_content(%{"a" => []}, "a")
      end)

    assertion_fails(
      Messages.expected_1_element_field(:a),
      [left: nil],
      fn -> 
        with_singleton_content(%{}, :a)
      end)

    assertion_fails(
      Messages.expected_1_element_field(:a),
      [left: 3],
      fn ->
        with_singleton_content(%{a: 3}, :a)
      end)
      
  end
end

