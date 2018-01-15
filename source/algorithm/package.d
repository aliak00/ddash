module algorithm;

import common: from;

public {
    import algorithm.flatmap;
    import algorithm.chunk;
    import algorithm.compact;
    import algorithm.concat;
    import algorithm.difference;
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
    alias initial = (range) => from!"std.range".dropBack(range, 1);
    import algorithm.intersection;
    import algorithm.join;
}