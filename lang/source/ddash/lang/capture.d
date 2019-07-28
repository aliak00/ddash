/**
    Capture variables with value semantics, useful in nogc code
*/
module ddash.lang.capture;

///
@("module example")
@nogc unittest {
	import std.range: only;
    import std.algorithm: map;
    auto xs = only(1, 2, 3);
    const a = 2, b = 3;
    xs.capture(a, b).map!(unpack!((x, a, b) => x * a * b));
}

/**
    The capture function takes a range as the first argument and a list of arguments you
    want to capture by value to pass along to another range

    Since:
        - 0.0.1
*/
auto capture(Range, Captures...)(auto ref Range range, auto ref Captures captures) {
    string mix() {
        import std.conv: to;
        string s = "zip(range, ";
        static foreach (i; 0 .. Captures.length) {
            s ~= "repeat(captures[" ~ i.to!string ~ "]),";
        }
        s ~= ")";
        return s;
    }
    import std.range: repeat, zip, only;
    return mixin(mix());
}

/**
    Complements the `capture` function by allowing you to unpack a capture tuple in the function
    you want to call it from.

    Since:
        - 0.0.1
*/
template unpack(alias func) {
    import std.typecons: Tuple;
    auto unpack(Types...)(Tuple!Types tup) {
        return func(tup.expand);
    }
}
