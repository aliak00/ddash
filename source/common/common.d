module common;

public template from(string moduleName) {
    mixin("import from = " ~ moduleName ~ ";");
}

version (unittest) {
    public import std.stdio;
    public import std.algorithm.comparison: equal;
    public import std.array;

    import std.range: isInputRange, ElementType;

    public bool equal(Range1, Range2)(Range1 r1, Range2 r2)
    if (isInputRange!(ElementType!Range1) && isInputRange!(ElementType!Range1))
    {
        import std.range: zip, walkLength;
        import std.algorithm;
        auto s1 = r1.walkLength;
        auto s2 = r2.walkLength;
        return s1 == s2 && r1.zip(r2).all!(a => .equal(a[0], a[1]));
    }
}
