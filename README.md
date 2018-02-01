## LodashD

A utility library that was inspired by the javascript library of the same name (minus the D).

```d
struct A {
    int x;
}

[A(7), A(0)].compactBy!"x";
// -> [A(7)]
```

### Features:
* Algorithms that are either non-trivial to figure out from D's stadard library Phobos
* Modularity
* Optional data type that provides safe chaining and access from functions that may or may not return values
* Functional utilities, such as expressive if/else chaining and currying
* A number of utilities for traits, meta programming, and D ranges.
