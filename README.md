## ddash

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
* operated on in parts:

    This would be akin to passing in a predicate that extracts a member variable from a type to operate on instead of operating on the whole type. These algorithms usually have a `By` prefix:
    ```d

    class C {
        int x;
    }
    auto arr1 = [new C(2), new C(3)];
    auto arr2 = [new C(2), new C(3)];
    assert(arr1.equalBy!"x"(arr2));
    ```
* operated on via unary or binary predicates:
    ```d
    import std.math: ceil;
    assert([2.1, 1.2].difference!ceil([2.3, 3.4]).equal([1.2]));
    assert([2.1, 1.2].difference!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]).equal([1.2]));
    ```

### Features:
* Algorithms that are possibly non-trivial to figure out from D's stadard library Phobos
* Algorithms that are not in D's standard library
* Ability to execute the algorithms on sequences other than ranges
* Integration with [Optional!T](https://github.com/aliak00/optional)
* Common utility functions
* Functional programming utilities
