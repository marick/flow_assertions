defmodule FlowAssertions do

@moduledoc """

This is a library of assertions for Elixir's ExUnit. It emphasizes two things:

1. Making tests easier to scan by capturing frequently-used assertions in
   functions that can be used in a pipeline.

   This library will appeal to people who prefer this:

      ```elixir
      VM.ServiceGap.accept_form(params, @institution)
      |> ok_content
      |> assert_valid
      |> assert_changes(id: 1,
                        in_service_datestring: @iso_date_1,
                        out_of_service_datestring: @iso_date_2,
                        reason: "reason")
      ```
      
   ... to this:
   
      ```elixir
      assert {:ok, changeset} = VM.ServiceGap.accept_form(params, @institution)
      assert changeset.valid?
      
      changes = changeset.changes
      assert changes.id == 1
      assert changes.in_service_datestring == @iso_date_1
      assert changes.out_of_service_datestring == @iso_date_2
      assert changes.reason == "reason"
      ```

   The key point here is that all of the `assert_*` functions in this package
   return their first argument to be used with later chained functions.

2. Error messages as helpful as those in the base ExUnit assertions:

<img src="https://raw.githubusercontent.com/marick/flow_assertions/main/pics/error2.png"/>

## Installation

Add `flow_assertions` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:flow_assertions, "~> 0.6", only: :test},
  ]
end
```

## Use

The easiest way is `use FlowAssertions`, which imports the most important modules, which are:
* `FlowAssertions.MapA`
* `FlowAssertions.MiscA`
* `FlowAssertions.EnumA`
* `FlowAssertions.StructA`

(in roughly that order). 

If you prefer to `alias` rather than `import`, note that all the
assertion modules end in `A`. That way, there's no conflict between
the module with map assertions (`FlowAssertions.MapA` and the `Map`
module itself.

## Reading error output

`ExUnit` has very nice reporting for assertions where a left-hand side is compared to a right-hand side, as in:


```elixir
assert x == y
```

The error output shows the values of both `x` and `y`, using
color-coding to highlight differences.

`FlowAssertions` uses that mechanism when appropriate. However, it
does more complicated comparisons, so the words `left` and `right`
aren't strictly accurate. So, suppose you're reading errors from code
like this:

```elixir
calculation
|> assert_something(expected)
|> assert_something_else(expected)
```

In the output, `left` will refer to some value extracted from
`calculation` and `right` will refer to a value extracted from
`expected` (most likely `expected` itself).

## Defining your own assertions

*TBD*

## Related code

*TBD*

## Change log

[Here](./changelog.html).


"""

  defmacro __using__(_) do
    quote do
      import FlowAssertions.EnumA
      import FlowAssertions.MapA
      import FlowAssertions.MiscA
      import FlowAssertions.StructA
      import FlowAssertions.Checkers
    end
  end
end
