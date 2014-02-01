# Changelog

## Next release (TBD)

 - Improve Type::Boolean to cast truthy and falsy objects to true and false.
 - Improve exception message when casting an out-of-range integer via one of
   the range-limited Integer type definitions (e.g., Int32)
 - Improve performance when casting already-valid objects.
 - Fixed tests for JRuby and Type::Int64
 - Fixed Type::Hash to make it less surprising on Ruby 2+ via `Kernel::Hash()`

## 0.1.0 (2014-01-29)

 - Initial Implementation
