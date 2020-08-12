defmodule FlowAssertions.StructA do
  use FlowAssertions.Define
  alias FlowAssertions.Messages

  @moduledoc """
  Assertions that apply only to structs, not maps.
  """
  
  @doc """
  Assert that the value is a particular module's struct.

  ```
  make_user("fred") |> assert_struct_named(User)
  ```

  For structs, this has the same purpose as
  `FlowAssertions.MiscA.assert_shape/2`. However, because
  it's not a macro, the second argument can be a variable. That makes it useful
  for building up larger assertion functions.
  
  """ 
  defchain assert_struct_named(value_to_check, module_name) do 
    boom! = fn msg ->
      elaborate_flunk(msg, left: value_to_check)
    end

    cond do
      is_struct(value_to_check) ->
        actual_name = value_to_check.__struct__
        if actual_name != module_name, 
          do: boom!.(Messages.wrong_struct_name(actual_name, module_name))
      is_map(value_to_check) ->
        boom!.(Messages.map_not_struct(module_name))
      :else ->
        boom!.(Messages.very_wrong_struct(module_name))
    end
  end
end
