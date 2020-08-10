defmodule FlowAssertions.Define do

  @moduledoc """
  `use` this module to get all the assertion-definition helpers at once.
  """

  defmacro __using__(_) do
    quote do
      import ExUnit.Assertions
      alias ExUnit.AssertionError 
     
      import FlowAssertions.Define.Defchain
      import FlowAssertions.Define.AssertionError
    end
  end
end
