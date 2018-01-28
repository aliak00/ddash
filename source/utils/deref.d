/**
    Dereferences an object depending on its type
*/
module utils.deref;

import common;

/// Derefernce a pointer
auto ref deref(T)(auto ref T t) if (from!"std.traits".isPointer!T) {
    return *t;
}

/// Dereference an optional
auto ref deref(T)(auto ref T t) if (from!"optional".isOptional!T) {
    return t.front;
}
