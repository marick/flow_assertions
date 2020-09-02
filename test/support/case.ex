defmodule FlowAssertions.Case do

  defmacro __using__(_) do 
    quote do 
      use ExUnit.Case, async: true
      alias ExUnit.AssertionError

      use FlowAssertions
      import FlowAssertions.AssertionA
      alias FlowAssertions.Messages
      alias FlowAssertions.Define.Tabular
    end  
  end
end
