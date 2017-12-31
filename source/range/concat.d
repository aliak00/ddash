module range.concat;

import std.range: isInputRange;

auto concat(R, V...)(R range, V values) if (isInputRange!R) {
    import std.range: chain, ElementType;
    static if (V.length) {
        static if (isInputRange!(V[0])) {
            return range.chain(values[0]).concat(values[1..$]);
        }
        
        static if (is(V[0] == ElementType!R)) {
            return range.chain([values[0]]).concat(values[1..$]);
        }
    } else {
        return range;
    }
}

unittest {
    import std.range: iota, array;
    assert([1, 2, 3].concat(4, [5], [6, 7], 8).array == 1.iota(9).array);
}
