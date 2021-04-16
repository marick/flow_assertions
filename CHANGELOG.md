# Changelog

## 0.7.0
* `FlowAssertions.TabularA` for tabular tests that are more broadly useful than 
  `Flowassertions.Define.Tabular`, which is for testing assertion definitions.
* Friendly error messages when arguments to `FlowAssertions.Checkers.in_any_order/1`
  are not `Enumerable`.

## 0.6.1

### Fixes

* `FlowAssertions.Checkers.in_any_order` failed to produce a correct
  assertion message if a mismatching Enumerable contained a value that
  didn't implement `String.Chars`.

## 0.6.0

### Additions

* `Flowassertions.Define.Tabular` functions now have a stable enough API to use safely.
* `FlowAssertions.Define.Tabular.nonflow_assertion_runners_for/1`
* `FlowAssertions.Checkers.has_slice/1`

### Tweaks

* `FlowAssertions.Define.BodyParts.adjust_assertion_error/2` now combines
  both `put` and `update!` behavior for replacements.

## 0.5.0

### Additions

* `FlowAssertions.Define.BodyParts.adjust_assertion_message/2`
* `FlowAssertions.MapA.refute_fields/2`

### Tweaks

* `FlowAssertions.Define.BodyParts.struct_must_have_key!/2` has a better error
  message.

## 0.4.0
### Features

* `FlowAssertions.Checkers`

  Checkers work with `FlowAssertions.MiscA.assert_good_enough/2` in a way
  that allows better error messages.
  
* `FlowAssertions.MiscA.ok_content/2` 

  Like `FlowAssertions.MiscA.ok_content/1`, but takes a second, name argument.
  The content must be a struct with that name (a module).

* `FlowAssertions.EnumA.singleton_content/2` 

  Like `FlowAssertions.EnumA.singleton_content/1`, but takes a second, name argument.
  The content must be a struct with that name (a module).

* `FlowAssertions.Define.BodyParts.elaborate_refute/3`

  A variant of `ExUnit.Assertions.refute/1` that allows creation of
  specialized error messages.

### Deprecations

* Deprecate `FlowAssertions.NoValueA.refute_no_value/3` in favor of `FlowAssertions.NoValueA.assert_values_assigned/3`
