/**
    Destructures objects
*/
module ddash.lang.destruct;

/**
    Destructs a range of elements in to the symbols that are provided

    Params:
        symbols = the variables you want to be set to the parts of a range
        range = the range you want destructed in to a set of variables

    Since:
        - 0.0.8
*/
template destructInto(symbols...) {
    void destructInto(Range)(auto ref Range range) {
        import std.range: array;
        auto arr = range.array;
        static foreach (i, symbol; symbols) {
           	symbol = arr[i];
        }
    }
}

///
unittest {
    int a, b, c;
    [1, 2, 3].destructInto!(a, b, c);
    assert(a == 1);
    assert(b == 2);
    assert(c == 3);
}
