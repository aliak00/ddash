/**
    sorts stuff
*/
module ddash.algorithm.sort;

import ddash.algorithm.internal.common;

/**
    Might or might not sort a range, depending on some static properties of a range.

    $(LI If already sorted and no predicate then no op)
    $(LI If not already sorted and no predicate then `sort(range)` is called)
    $(LI If not already sorted and a predicate is provided then `sort!pred(range)` is called)
    $(LI Else it's a no op and you get back the same range you passed in)

    Since:
        0.1.0
*/
auto ref maybeSort(alias less = null, Range)(auto ref Range range) {
    import std.algorithm: sort;
    import bolts.traits: isNullType;
    import bolts.range: isSortedRange;
    import std.functional: binaryFun;
    static if (isNullType!less) {
        static if (isSortedRange!Range) {
            return range;
        } else static if (is(typeof(sort(range)))) {
            return sort(range);
        } else {
            return range;
        }
    } else static if (is(typeof(sort!(binaryFun!less)(range)))) {
        return sort!(binaryFun!less)(range);
    } else {
        return range;
    }
}

///
unittest {
    import bolts.range: isSortedRange;

    struct A { // unsortable
        int i;
    }

    struct B { // sortable
        int i;
        bool opCmp(B a) {
            return i < a.i;
        }
    }

    static assert( isSortedRange!([1].maybeSort));
    static assert(!isSortedRange!([A()].maybeSort));
    static assert( isSortedRange!([B()].maybeSort));
    static assert( isSortedRange!([A()].maybeSort!"a.i < b.i"));
}


/**
    Maybe sorts a range using `maybeSort` by a publicly visible member variable or property of `ElemntType!Range`

    Since:
        0.1.0
*/
auto ref maybeSortBy(string member, alias less = null, Range)(auto ref Range range) {
    import std.algorithm: sort;
    import bolts.traits: isNullType;
    import bolts.range: isSortedRange;
    import std.functional: binaryFun;
    static if (isNullType!less) {
        static if (is(typeof(sortBy!member(range)))) {
            return sortBy!member(range);
        } else {
            return range;
        }
    } else static if (is(typeof(sortBy!(member, binaryFun!less)(range)))) {
        return sortBy!(member, binaryFun!less)(range);
    } else {
        return range;
    }
}

///
unittest {
    import bolts.range: isSortedRange;

    struct A { // unsortable
        int i;
    }

    struct B { // sortable
        int i;
        bool opCmp(B a) {
            return i < a.i;
        }
    }

    struct C {
        B b;
        A a;
    }

    static assert(!isSortedRange!([C()].maybeSortBy!"a"));
    static assert( isSortedRange!([C()].maybeSortBy!"b"));
    static assert( isSortedRange!([C()].maybeSortBy!("a", "a.i < b.i")));
}

/**
    Sorts a range using the standard library sort by a publicly visible member variable or property of `ElemntType!Range`

    Since:
        0.1.0
*/
auto sortBy(string member, alias less = "a < b", Range)(Range range) {
    import std.algorithm: stdSort = sort;
    import std.functional: binaryFun;
    import ddash.algorithm.internal: valueBy;
    return range.stdSort!((a, b) => binaryFun!less(valueBy!member(a), valueBy!member(b)));
}

///
unittest {
    struct A {
        int i;
    }
    auto a = [A(3), A(1), A(2)];
    assert(a.sortBy!"i".equal([A(1), A(2), A(3)]));
}
