defmodule FlowAssertions.Define.Defchecker do
  import FlowAssertions.Define.BodyParts
  alias FlowAssertions.Messages

  
  @moduledoc """
  Code to support writing checkers like the ones in `FlowAssertions.Checkers`.

  Note that this is a work in progress, so be prepared for change.
  """

  defmodule Failure do
    @moduledoc false

    defstruct mfa: {nil, nil, []}, actual: nil

    # A "by order of arguments" or "boa" constructor.
    # A shoutout to Guy Steele's /Common Lisp: The Language/.
    # The order is the order in a pipelined call.
    def boa(actual, name, expected) do
      %__MODULE__{
        mfa: {"ignored", name, [expected]},
        actual: actual}
    end
  end

  def fail_helpfully(%Failure{} = failure) do
    fail_helpfully(failure, [])
  end

  def fail_helpfully(%Failure{} = failure, message) when is_binary(message) do
    fail_helpfully(failure, message, left: failure.actual)
  end

  def fail_helpfully(%Failure{} = failure, opts) when is_list(opts) do
    fail_helpfully(failure, Messages.failed_checker(checker_name(failure.mfa)), opts)
  end

  def fail_helpfully(%Failure{} = _failure, message, opts) do
    elaborate_flunk(message, opts)
  end

  defp checker_name({_module, function, args}) do 
    printable_args =
      args
      |> Enum.map(&inspect/1)
      |> Enum.join(", ")
    
    "#{function}(#{printable_args})"
  end

  # Sketch for if a `defchecker` macro becomes useful.
  # This hasn't been made to work with `when` annotations. See `defchain`.
  @doc false
  defmacro defchecker(head, do: predicate) do
    {name, _, args} = head
    quote do
      def unquote(head) do 
        fn outer_actual ->
          if unquote(predicate).(outer_actual) do
            true
          else
            Failure.new(mfa: {__MODULE__, unquote(name), unquote(args)}, actual: outer_actual)
          end
        end
      end
    end
  end
end
