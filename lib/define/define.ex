defmodule FlowAssertions.Define do

  defmacro __using__(_) do
    quote do
      import ExUnit.Assertions
      alias ExUnit.AssertionError 
     
      import FlowAssertions.Define.Defchain
      import FlowAssertions.Define.Helpers
      alias FlowAssertions.Define.Messages
    end
  end
end
