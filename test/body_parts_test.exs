defmodule FlowAssertions.Define.BodyPartsTest do
  use FlowAssertions.Case
  import FlowAssertions.Define.BodyParts

  defstruct a: 1, b: 2

  @possible_keys [:a, :b]

  test "struct_must_have_key!" do
    a = Tabular.assertion_runners_for(&struct_must_have_key!/2)
    struct = %__MODULE__{}  # any struct will do
    
    [struct, :a          ] |> a.pass.()
    [struct, :not_present] |> a.fail.(message(:not_present))
                           |> a.plus.(left: in_any_order(@possible_keys))
    # When called on a non-struct, checks nothing.
    [%{},    :a          ] |> a.pass.()
  end

  test "struct_must_have_keys!" do
    a = Tabular.assertion_runners_for(&struct_must_have_keys!/2)
    struct = %__MODULE__{}  # any struct will do
    
    [struct, [:a, :b]          ] |> a.pass.()
    [struct, [:a, :not_present]] |> a.fail.(message(:not_present))
                                 |> a.plus.(left: in_any_order(@possible_keys))

    # Only first error is found]
    [struct, [:a, :missing, :also_missing]] |> a.fail.(message(:missing))
    
    # When called on a non-struct, checks nothing.
    [%{},    [:a]              ] |> a.pass.()
  end
  
  # ----------------------------------------------------------------------------
  
  defp message(key) do
    # The name is extracted from the struct, so actual value doesn't matter.
    name_holder = %__MODULE__{}
    Messages.required_key_missing(key, name_holder)
  end
end
