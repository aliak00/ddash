module ddash.common.ctstrings;

package(ddash) template CTStrings(A...) {
    static if (!A.length) {
        enum CTStrings = "";
    } else {
        import bolts.traits: StringOf;
        import std.meta: staticMap;
        import std.array: join;
        enum CTStrings = [staticMap!(StringOf, A)].join(",");
    }
}
