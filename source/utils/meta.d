/**
    Utilities that operate over type lists
*/
module utils.meta;

/**
    Flattens a list of ranges and not ranges.

    If a type is a range then its `ElementType` is used
*/
template FlattenRanges(Values...) {
    import std.meta: AliasSeq;
    static if (Values.length)
    {
        import std.range: isInputRange;
        alias Head = Values[0];
        alias Tail = Values[1..$];
        static if (isInputRange!Head)
        {
            import std.range: ElementType;
            alias FlattenRanges = FlattenRanges!(ElementType!Head, FlattenRanges!Tail);
        }
        else
        {
            alias FlattenRanges = AliasSeq!(Head, FlattenRanges!Tail);
        }
    }
    else
    {
        alias FlattenRanges = AliasSeq!();
    }
}

///
unittest {
    import std.algorithm: filter;
    import std.meta: AliasSeq;
    import optional: Optional;

    alias R1 = typeof([1, 2, 3].filter!"true");
    alias R2 = typeof([1.0, 2.0, 3.0]);

    static assert(is(FlattenRanges!(int, double) == AliasSeq!(int, double)));
    static assert(is(FlattenRanges!(int, R1, R2) == AliasSeq!(int, int, double)));
    static assert(is(FlattenRanges!(Optional!int, int*, R1) == AliasSeq!(int, int*, int)));

    import std.traits: CommonType;
    static assert(is(CommonType!(FlattenRanges!(int, R1, R2, float)) == double));
}

/**
    Returns the types of all values given.

    If a T is an expression it is resolved with `typeof` else it is just appended

    Returns:
        AliasSeq of the resulting types
*/
template typesOf(Values...) {
    import std.meta: AliasSeq;
    import std.traits: isExpressions;
    static if (Values.length)
    {
        static if (isExpressions!(Values[0]))
        {
            alias T = typeof(Values[0]);
        }
        else
        {
            alias T = Values[0];
        }
        alias typesOf = AliasSeq!(T, typesOf!(Values[1..$]));
    }
    else
    {
        alias typesOf = AliasSeq!();
    }
}

///
unittest {
    import std.meta: AliasSeq;
    static assert(is(typesOf!("hello", 1, 2, 3.0, real) == AliasSeq!(string, int, int, double, real)));
}
