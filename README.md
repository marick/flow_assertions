# FlowAssertions

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

   <img src="/pics/error2.png"/>

## Documentation

[https://hexdocs.pm/flow_assertions](https://hexdocs.pm/flow_assertions)

## Installation

Add `flow_assertions` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:flow_assertions, "~> 0.2", only: :test},
  ]
end
```

