

## ddash

[![Latest version](https://img.shields.io/dub/v/ddash.svg)](https://code.dlang.org/packages/ddash) [![Build Status](https://travis-ci.org/aliak00/ddash.svg?branch=master)](https://travis-ci.org/aliak00/ddash) [![codecov](https://codecov.io/gh/aliak00/ddash/branch/master/graph/badge.svg)](https://codecov.io/gh/aliak00/ddash) [![license](https://img.shields.io/github/license/aliak00/ddash.svg)](https://github.com/aliak00/ddash/blob/master/LICENSE)

A utility library that was inspired by the a javascript library called [lodash](https://lodash.com/). The algorithms operate on sequences that are either:

 * [value sequences](https://dlang.org/spec/template.html#variadic-templates):
    ```d
    assert(1.concat(2, 3, 4).array == [1, 2, 3, 4]);
    ```
* [ranges](https://dlang.org/phobos/std_range_primitives.html):
    ```d
    assert(1.concat([2, 3, 4]).array == [1, 2, 3, 4]);
    ```
* a mixture of the above two:
    ```d
    assert(1.concat([2, 3], 4).array == [1, 2, 3, 4]);
    ```
* [associative arrays](https://dlang.org/spec/hash-map.html):
    ```d
    auto aa = ["a": 1, "b": 0, "c": 2];
    assert(aa.compactValues!(a => a == 0) == ["a": 1, "c": 2]);
    ```

Furthermore, a number of algorithms allow you to:

* operate on members of types:

    This would be akin to passing in a predicate that extracts a member variable from a type to operate on instead of operating on the whole type. These algorithms usually have a `By` prefix:
    ```d

    class C {
        int x;
    }
    auto arr1 = [new C(2), new C(3)];
    auto arr2 = [new C(2), new C(3)];
    assert(arr1.equalBy!"x"(arr2));
    ```
* operate via unary or binary predicates:
    ```d
    import std.math: ceil;
    assert([2.1, 2.4, 1.2, 2.9].difference!ceil([2.3, 0.1]).equal([1.2]));
    assert([2.1, 2.4, 1.2, 2.9].difference!((a, b) => ceil(a) < ceil(b))([2.3, 3.4]).equal([1.2]));
    ```
* or both:
    ```d
    struct A {
        int x;
    }
    auto arr = [A(4), A(8), A(12)];
    assert(arr.pullBy!("x", a => a / 2)(5, 9).array == [A(12)]);
    ```

### Features:
* Algorithms that are possibly non-trivial to figure out from D's stadard library Phobos
* Algorithms that are not in D's standard library
* Ability to execute the algorithms on sequences other than ranges
* Integration with [Optional!T](https://github.com/aliak00/optional)
* Common utility functions
* Functional programming utilities

### Subpackages:

* **algorithm**: contains algorithms that operate mostly on sequences
* **ranges**: contains navigational algorithms over ranges (moving/jumpting/iterating/etc)
* **functional**: contains utilties for functional programming
* **lang**: contains techniques that fill in required language bits (or just stuff I didn't know where to put)
* **utils**: contains utility types and functions

### Benchmarks

There's a benchmark dub configuration that can be used to run algorithms and check their speeds. The idea behind this is supposed to be to help with regressions once I figure out how to generate reports.
