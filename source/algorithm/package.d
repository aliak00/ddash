module algorithm;

import common;

public {
    import algorithm.flatmap;
    import algorithm.chunk;
    import algorithm.compact;
    import algorithm.concat;
    import algorithm.difference; // also differenceBy
    // TODO: differenceWith
    import std.range: drop;
    import std.range: dropRight = dropBack;
    import algorithm.droprightwhile;
    alias dropWhile(alias pred) = (range) => from!"std.algorithm".until!(from!"std.functional".not!pred)(range);
    import std.algorithm: fill;
    import phobos: findIndex = countUntil;
    import algorithm.findlastindex;
    import algorithm.flatten;
    import algorithm.flattendeep;
    import std.array: fromPairs = assocArray;
}