defmodule FlowAssertions.Define.BodyPartsTest do
  use FlowAssertions.Case
  import FlowAssertions.Define.BodyParts

  defstruct a: 1, b: 2

  test "struct_must_have_key[s]!" do
    struct = %__MODULE__{}

    assert struct_must_have_key!(struct, :a) == struct
    assert struct_must_have_keys!(struct, [:a, :b]) == struct

    assertion_fails(Messages.required_key_missing(:not_present, struct),
      fn -> 
        struct_must_have_key!(struct, :not_present)
      end)

    assertion_fails(Messages.required_key_missing(:not_present, struct),
      fn -> 
        struct_must_have_keys!(struct, [:a, :not_present, :also_not_present])
      end)
  end
end
