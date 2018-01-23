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
        import optional: isOptional;

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
        else static if (isOptional!Head)
        {
            import optional: OptionalTarget;
            alias Flatten = AliasSeq!(OptionalTarget!Head, Flatten!Tail);
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
}
