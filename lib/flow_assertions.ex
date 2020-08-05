defmodule FlowAssertions do

  defmacro __using__(_) do
    quote do
      import FlowAssertions.AssertionA
      import FlowAssertions.EnumA
      import FlowAssertions.MapA
      import FlowAssertions.MiscA
      import FlowAssertions.StructA
    end
  end
end
