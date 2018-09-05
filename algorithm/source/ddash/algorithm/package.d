/**
    Contains a number of algorithms that operate on sequences. These sequences can be:

    <li>$(LINK2 https://dlang.org/spec/template.html#variadic-templates, value sequences):
    ---
    assert(1.concat(2, 3, 4).array == [1, 2, 3, 4]);
    ---
    <li>$(LINK2 https://dlang.org/phobos/std_range_primitives.html, ranges):
    ---
    assert(1.concat([2, 3, 4]).array == [1, 2, 3, 4]);
    ---
    <li>a mixture of the above two:
    ---
    assert(1.concat([2, 3], 4).array == [1, 2, 3, 4]);
    ---
    <li>$(LINK2 https://dlang.org/spec/hash-map.html, associative arrays):
    ---
    auto aa = ["a": 1, "b": 0, "c": 2];
    assert(aa.compactValues!(a => a == 0) == ["a": 1, "c": 2]);
    ---

    Furthermore, a number of algorithms allow you to:

    <li>operate on members of types:

    This would be akin to passing in a predicate that extracts a member variable from a type to
    operate on instead of operating on the whole type. These algorithms usually have a `By` prefix:
    ---
    class C {
        int x;
    }
    auto arr1 = [new C(2), new C(3)];
    auto arr2 = [new C(2), new C(3)];
    assert(arr1.equalBy!"x"(arr2));
    ---
    <li>operate via unary or binary predicates:
    ---
    import std.math: ceil;
    assert([2.1, 1.2].difference!ceil([2.3, 3.4]).equal([1.2]));
    assert([2.1, 1.2].difference!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]).equal([1.2]));
    ---
    <li> or both:
    ---
    struct A {
        int x;
    }
    auto arr = [A(4), A(8), A(12)];
    assert(arr.pullBy!("x", a => a / 2)(5, 9).array == [A(12)]);
    ---

Algorithms:

$(TABLE
$(TR $(TH Module) $(TH Functions) $(TH Properties) $(TH Description))
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.compact, `compact`))
    $(TD
        $(DDOX_NAMED_REF algorithm.compact.compact, `compact`)<br>
        $(DDOX_NAMED_REF algorithm.compact.compactBy, `compactBy`)<br>
        $(DDOX_NAMED_REF algorithm.compact.compactValues, `compactValues`)<br>
        )
    $(TD)
    $(TD Creates a range or associative array with all null/predicate values removed.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.concat, `concat`))
    $(TD
        $(DDOX_NAMED_REF algorithm.concat.concat, `concat`)
        )
    $(TD)
    $(TD Concatenates ranges and values together to a new range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.difference, `difference`))
    $(TD
        $(DDOX_NAMED_REF algorithm.difference.difference, `difference`)<br>
        $(DDOX_NAMED_REF algorithm.difference.differenceBy, `differenceBy`)<br>
        )
    $(TD)
    $(TD Creates a range of values not included in the other given set of values)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.equal, `equal`))
    $(TD
        $(DDOX_NAMED_REF algorithm.equal.equal, `equal`)<br>
        $(DDOX_NAMED_REF algorithm.equal.equalBy, `equalBy`)<br>
        )
    $(TD)
    $(TD Tells you if two things are equal)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.fill, `fill`))
    $(TD
        $(DDOX_NAMED_REF algorithm.fill.fill, `fill`)
        )
    $(TD mutates)
    $(TD Assigns value to each element of input range.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.flatmap, `flatmap`))
    $(TD
        $(DDOX_NAMED_REF algorithm.flatmap.flatMap, `flatMap`)
        )
    $(TD)
    $(TD Maps and flattens a range.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.flatten, `flatten`))
    $(TD
        $(DDOX_NAMED_REF algorithm.flatten.flatten, `flatten`)<br>
        $(DDOX_NAMED_REF algorithm.flatten.flattenDeep, `flattenDeep`)<br>
        )
    $(TD)
    $(TD Flattens a range by removing nesting levels values)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.frompairs, `frompairs`))
    $(TD
        $(DDOX_NAMED_REF algorithm.frompairs.fromPairs, `fromPairs`)
        )
    $(TD)
    $(TD Returns a newly allocated associative array from a range of key/value tuples)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.index, `index`))
    $(TD
        $(DDOX_NAMED_REF algorithm.index.indexWhere, `indexWhere`)<br>
        $(DDOX_NAMED_REF algorithm.index.lastIndexWhere, `lastIndexWhere`)<br>
        $(DDOX_NAMED_REF algorithm.index.indexOf, `indexOf`)<br>
        $(DDOX_NAMED_REF algorithm.index.lastIndexOf, `lastIndexOf`)<br>
        )
    $(TD)
    $(TD Returns `optional` index of an element in a range.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.intersection, `intersection`))
    $(TD
        $(DDOX_NAMED_REF algorithm.intersection, `intersection`)
        )
    $(TD)
    $(TD Creates a range of unique values that are included in the other given set of values)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.pull, `pull`))
    $(TD
        $(DDOX_NAMED_REF algorithm.pull.pull, `pull`)<br>
        $(DDOX_NAMED_REF algorithm.pull.pullAt, `pullAt`)<br>
        $(DDOX_NAMED_REF algorithm.pull.pullBy, `pullBy`)<br>
        )
    $(TD)
    $(TD Pulls elements out of a range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.remove, `remove`))
    $(TD
        $(DDOX_NAMED_REF algorithm.remove.remove, `remove`)
        )
    $(TD mutates)
    $(TD Removed elements from a range by unary predicate)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.reverse, `reverse`))
    $(TD
        $(DDOX_NAMED_REF algorithm.reverse.reverse, `reverse`)
        )
    $(TD mutates)
    $(TD Reverses a range in place)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.sort, `sort`))
    $(TD
        $(DDOX_NAMED_REF algorithm.sort.sortBy, `sortBy`)<br>
        $(DDOX_NAMED_REF algorithm.sort.maybeSort, `maybeSort`)<br>
        $(DDOX_NAMED_REF algorithm.sort.maybeSortBy, `maybeSortBy`)
        )
    $(TD)
    $(TD Provides various ways for sorting a range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.stringify, `stringify`))
    $(TD
        $(DDOX_NAMED_REF algorithm.stringify.stringify, `stringify`)<br>
        $(DDOX_NAMED_REF algorithm.stringify.stringifySeperatedBy, `stringifySeperatedBy`)<br>
        )
    $(TD)
    $(TD Converts all elements in range into a string separated by separator.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.algorithm.zip, `zip`))
    $(TD
        $(DDOX_NAMED_REF algorithm.zip.zipEach, `zipEach`)
        )
    $(TD)
    $(TD Zips up ranges together)
    )
)
*/
module ddash.algorithm;

import ddash.common;

public {
    import ddash.algorithm.flatmap;
    import ddash.algorithm.compact;
    import ddash.algorithm.concat;
    import ddash.algorithm.difference;
    import ddash.algorithm.equal;
    import ddash.algorithm.fill;
    import ddash.algorithm.flatmap;
    import ddash.algorithm.flatten;
    import ddash.algorithm.frompairs;
    import ddash.algorithm.index;
    import ddash.algorithm.intersection;
    import ddash.algorithm.pull;
    import ddash.algorithm.remove;
    import ddash.algorithm.reverse;
    import ddash.algorithm.sort;
    import ddash.algorithm.stringify;
    import ddash.algorithm.zip;
}
