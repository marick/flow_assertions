defmodule FlowAssertions.Checkers do

  @moduledoc """
  Functions that create handy predicates for use with `FlowAssertions.MiscA.assert_good_enough/2`
  """

  @doc """
  TBD
  """

  def in_any_order(_expected) do
    {:__checker__, {__MODULE__, :in_any_order}, fn _actual ->
      false
    end}
  end
  
  @doc """
  TBD
  """
  def contains(_part) do
  end
  
end  
