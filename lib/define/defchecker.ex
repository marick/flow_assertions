defmodule FlowAssertions.Define.Defchecker do
  import FlowAssertions.Define.BodyParts
  alias FlowAssertions.Messages
  alias FlowAssertions.MiscA
  import FlowAssertions.AssertionA

  
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

  # This hasn't been made to work with `when` annotations.
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



  def make_runners(checker) do
    run = fn [actual, expected] ->
      MiscA.assert_good_enough(actual, checker.(expected))
    end
    fail = fn
      condensed_assertion, %Regex{} = regex ->
        assertion_fails(regex, fn -> run.(condensed_assertion) end)
      condensed_assertion, message when is_binary(message) ->
        assertion_fails(message, fn -> run.(condensed_assertion) end)
      condensed_assertion, opts when is_list(opts) ->
        assertion_fails(~r/.*/, opts, fn -> run.(condensed_assertion) end)
    end

    %{pass: run,
      fail: fail,
      view:    fn args ->          run.(args) end,
      view_:   fn args, _ ->       run.(args) end,
      view__:  fn args, _, _ ->    run.(args) end,
      view___: fn args, _, _, _ -> run.(args) end,
    }
  end

  
    
  
end
