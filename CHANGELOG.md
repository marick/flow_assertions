# Changelog

## 0.4.0 (pending)
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
