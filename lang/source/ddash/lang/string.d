/**
    Languages level tools that work on strings
*/
module ddash.lang.string;

import ddash.common;

private alias allOfString(Strings...) = from!"std.meta".allSatisfy!(
    from!"std.meta".ApplyLeft!(from!"bolts.traits".isOf, string), Strings
);

private string mixinStringLines(long length, string aliasName, string delimiter)() {
    import std.conv: to;
    string ret;
    static foreach (i; 0 .. length) {
        ret ~= aliasName ~ "[" ~ i.to!string ~ "]";
        static if (i != (length - 1)) {
            ret ~= delimiter;
        }
    }
    return ret;
}

unittest {
    assert(
        mixinStringLines!(3, "A", "..") == `A[0]..A[1]..A[2]`
    );
}

/**
    Use this to create a multiline string out of literals, vars, and unary functions that return strings

    Params:
        Strings = list of string to concat, each arg is a new line

    Since:
        - 0.10.0
*/
string multiline(Strings...)() if (allOfString!Strings) {
    mixin(
        "return " ~ mixinStringLines!(Strings.length, "Strings", ` ~ "\n" ~`) ~ ";"
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

/**
    Use this to breakup a singleline string in to multiple lines and show the intent of it being one line

    Params:
        Strings = list of string to concat in to a single string

    Since:
        - 0.10.0
*/
string singleline(Strings...)() if (allOfString!Strings) {
    mixin(
        "return " ~ mixinStringLines!(Strings.length, "Strings", "~") ~ ";"
    );
}

///
@("Singleline string creates correct string")
unittest {
    static string var = "booya";
    static string func() { return var; }

    assert(
        singleline!(
            "this is a singleline string that does not",
            "  span multiple lines yo!",
            var,
            func
        ) == "this is a singleline string that does not  span multiple lines yo!booyabooya"
    );
}
