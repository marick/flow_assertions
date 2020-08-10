defmodule FlowAssertions.NoValueA do
  use FlowAssertions.Define
  alias FlowAssertions.Messages

  @moduledoc """
  These assertions assume a convention of initializing keys in a map
  to an "I have no value" value, with the expectation that they
  will later be given real values.

  Such a convention is useful in multi-step construction of, for
  example, ExUnit assertion errors. They are structures initialized to
  :ex_unit_no_meaningful_value. The values are then set by an
  assertion error. Moreover, they can be reset by code that rescues an
  error. Several functions in this package make use of that. See
  `FlowAssertions.Define.AssertionError.adjust_assertion_error/2` for an
  example.

  Use this module with `use`, providing the no-value value:

      use FlowAssertions.NoValueA, no_value: :_nothing
      ...
      result |> assert_no_value([:key1, key2])

  If you use the same no-value value widely, consider using this module
  once and importing that:

      defmodule My.NoValueA do 
        use FlowAssertions.NoValueA, no_value: :ex_unit_no_meaningful_value
      end

      defmodule MyTestModule
        import My.NoValueA
        ...
        result |> assert_no_value([:key1, key2])

  If you don't use `use`, you can provide the no-value value on each
  call:


      import FlowAssertions.NoValueA
      ...
      result |> assert_no_value([:key1, :key2], :ex_unit_no_meaningful_value)

  The default no-value value is `nil`.
  """
  
  # ----------------------------------------------------------------------------
  @doc """
  Assert that one or more keys in a map have no value.

  Note that the second argument can be either a singleton key or a list.
  """

  def assert_no_value(map, key, no_value \\ nil)
  
  defchain assert_no_value(map, keys, no_value) when is_list(keys) do
    for key <- keys do 
      actual = Map.fetch!(map, key)
      elaborate_assert(actual == no_value,
        Messages.not_no_value(key, no_value),
        expr: AssertionError.no_value,
        left: actual)
    end
  end

  def assert_no_value(map, key, no_value),
    do: assert_no_value(map, [key], no_value)

  @doc """
  Assert that one or more keys in a map have values.

  Note that the second argument can be either a singleton key or a list.
  """

  def refute_no_value(map, keys, no_value \\ nil)
  
  defchain refute_no_value(map, keys, no_value) when is_list(keys) do
    for key <- keys do 
      actual = Map.fetch!(map, key)
      elaborate_assert(actual != no_value,
        Messages.not_value(key),
        expr: AssertionError.no_value,
        left: actual)
    end
  end

  def refute_no_value(map, key, no_value),
    do: refute_no_value(map, [key], no_value)


  defmacro __using__(opts) do
    no_value = Keyword.get(opts, :no_value)
    
    quote do
      alias FlowAssertions.NoValueA

      def assert_no_value(map, keys),
        do: NoValueA.assert_no_value(map, keys, unquote(no_value))

      def refute_no_value(map, keys),
        do: NoValueA.refute_no_value(map, keys, unquote(no_value))
    end
  end
end
