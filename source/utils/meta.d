/**
    Utilities that operate over type lists
*/
module utils.meta;

/**
    Flattens a list of types. I.e. removes pointer, array, and optional wrappings
*/
template Flatten(Values...) {
    import std.meta: AliasSeq;
    static if (Values.length)
    {
        import std.range: isInputRange;
        import std.traits: isPointer;

        alias Head = Values[0];
        alias Tail = Values[1..$];
        static if (isInputRange!Head)
        {
            import std.range: ElementType;
            alias Flatten = AliasSeq!(ElementType!Head, Flatten!Tail);
        }
        else static if (isPointer!Head)
        {
            import std.traits: PointerTarget;
            alias Flatten = AliasSeq!(PointerTarget!Head, Flatten!Tail);
        }
        else
        {
            alias Flatten = AliasSeq!(Head, Flatten!Tail);
        }
    }
    else
    {
        alias Flatten = AliasSeq!();
    }
}

///
unittest {
    import std.algorithm: filter;
    import std.meta: AliasSeq;
    import optional: Optional;

    alias R1 = typeof([1, 2, 3].filter!"true");
    alias R2 = typeof([1.0, 2.0, 3.0]);

    static assert(is(Flatten!(int, double) == AliasSeq!(int, double)));
    static assert(is(Flatten!(int, R1, R2, float) == AliasSeq!(int, int, double, float)));
    static assert(is(Flatten!(Optional!int, int*, R1) == AliasSeq!(int, int, int)));

    import std.traits: CommonType;
    static assert(is(CommonType!(Flatten!(int, R1, R2, float)) == double));
}

/**
    Flattens a list of ranges and not ranges.

    The difference between this and `Flatten` is that this one will not stomp out
    pointer types
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
