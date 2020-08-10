defmodule FlowAssertions.StructA do
  use FlowAssertions.Define
  
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
  defchain assert_struct_named(value_to_check, module_name)
  when is_struct(value_to_check) do
    actual_name = value_to_check.__struct__
    assert actual_name == module_name,
      "Expected a `#{inspect module_name}` but got a `#{inspect actual_name}`"
  end

  def assert_struct_named(value_to_check, module_name)
  when is_map(value_to_check) do
    flunk """
    Expected a `#{inspect module_name}` but got a plain Map:
    #{inspect value_to_check}
    """
  end

  def assert_struct_named(value_to_check, module_name),
    do: flunk "Expected a `#{inspect module_name}` but got `#{value_to_check}`"
end
