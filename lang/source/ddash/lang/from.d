/**
    Implementation of the D Import Idiom
*/
module ddash.lang.from;

import ddash.common: commonfrom = from;

/**
    Encompases the from import idiom in an opDispatch version

    Since:
        - 0.12.0

    See_Also:
        <li> https://dlang.org/blog/2017/02/13/a-new-import-idiom/
        <li> https://forum.dlang.org/thread/gdipbdsoqdywuabnpzpe@forum.dlang.org
*/
enum from = commonfrom;

///
@("from - example")
unittest {
    // Call a function
    auto _0 = from.std.algorithm.map!"a"([1, 2, 3]);
    // Assign an object
    auto _1 = from.std.datetime.stopwatch.AutoStart.yes;

    // compile-time constraints
    auto length(R)(R range) if (from.std.range.isInputRange!R) {
        return from.std.range.walkLength(range);
    }

    assert(length([1, 2]) == 2);
}

@("Non existent functions should not be callable")
unittest {
    static assert(!__traits(compiles, { from.std.stdio.thisFunctionDoesNotExist(42); }));
}
