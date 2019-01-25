/**
    Languages level tools that work on strings
*/
module ddash.lang.string;

import ddash.common;

private alias allOfString(Strings...) = from!"std.meta".allSatisfy!(
    from!"std.meta".ApplyLeft!(from!"bolts.traits".isOf, string), Strings
);

/**
    Use this to create a multiline string out of literals, vars, and unary functions that return strings

    Params:
        Strings = list of string to concat, each arg is a new line

    Since:
        - 0.10.0
*/
string multiline(Strings...)() if (allOfString!Strings) {
    string apply() {
        import std.conv: to;
        string ret;
        static foreach (i, s; Strings) {
            ret ~= "Strings[" ~ i.to!string ~ "]";
            static if (i != (Strings.length - 1)) {
                ret ~= ` ~ "\n" ~`;
            }
        }
        return ret;
    }
    mixin(
        "return " ~ apply ~ ";"
    );
}

///
@("Multiline string creates correct string")
unittest {
    static string var = "booya";
    static string func() { return var; }

    assert(
        multiline!(
            "this is a multiline string that",
            "  spans multiple lines yo!",
            var,
            func
        ) == "this is a multiline string that\n  spans multiple lines yo!\nbooya\nbooya"
    );
}
