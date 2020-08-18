defmodule FlowAssertions.Define.Defchecker do
  import FlowAssertions.Define.BodyParts
  alias FlowAssertions.Messages
  
  @moduledoc """
  """

  defmodule Failure do
    defstruct mfa: {nil, nil, []}, actual: nil

    def new(opts) do
      %__MODULE__{
        mfa: Keyword.fetch!(opts, :mfa),
        actual: Keyword.fetch!(opts, :actual)
      }
    end
  end

  def flunk(%Failure{} = failure) do
    elaborate_flunk(Messages.failed_checker(checker_name(failure.mfa)),
      left: failure.actual)
  end

  defp checker_name({_module, function, args}) do 
    printable_args =
      args
      |> Enum.map(&inspect/1)
      |> Enum.join(", ")
      |> IO.inspect
    
    "#{function}(#{printable_args})"
  end
end
