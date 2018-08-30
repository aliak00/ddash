/**
    Creates an infix operator out of functions
*/
module ddash.functional.infix;

///
unittest {
    static import std.algorithm.comparison;
    alias min = Infix!(std.algorithm.comparison.min);
    assert(1 /min/ 3 == 1);
}

/**
    Allows you to create an infix operator out of a functions

    The function cannot have any template arguments and must be
    binary

    See_Also:
        - https://forum.dlang.org/post/ldiwiffdyzeswggytudh@forum.dlang.org
*/
struct Infix(alias fn, string operator = "/") {
    static auto opBinaryRight(string op : operator, T...)(T value1) {
        struct Result {
            auto opBinary(string op : operator, U...)(U value2)
            if (__traits(compiles, fn(value1, value2))) {
                return fn(value1, value2);
            }
        }

        Result result;
        return result;
    }
}
