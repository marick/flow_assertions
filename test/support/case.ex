defmodule FlowAssertions.Case do

  defmacro __using__(_) do 
    quote do 
      use ExUnit.Case, async: true
      alias ExUnit.AssertionError

      use FlowAssertions
      import FlowAssertions.Define.AssertionA
      alias FlowAssertions.Define.Messages
      
    end  
  end
end
