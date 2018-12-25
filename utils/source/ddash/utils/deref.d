/**
    Dereferences an object depending on its type
*/
module ddash.utils.deref;

import ddash.common;

/**
    Dereferences a thing

    Could be a range, a pointer, or a nullable.

    Since:
        - 0.0.1
*/
auto ref deref(T)(auto ref T t) if (from!"std.traits".isPointer!T) {
    return *t;
}

/// Ditto
auto ref deref(T)(auto ref T t) if (from!"std.range".isInputRange!T) {
    return t.front;
}

import std.typecons: Nullable;
/// Ditto
auto ref deref(T)(auto ref Nullable!T t) {
    return t.get;
}

///
@("derefs different types")
unittest {
    import std.typecons: nullable;
    auto a = nullable(1);
    auto b = new int(1);
    auto c = [1];

    assert(a.deref == 1);
    assert(b.deref == 1);
    assert(c.deref == 1);
}
