/**
    Dereferences an object depending on its type
*/
module ddash.utils.deref;

import ddash.common;

/// Derefernce a pointer
auto ref deref(T)(auto ref T t) if (from!"std.traits".isPointer!T) {
    return *t;
}

/// Dereference a range
auto ref deref(T)(auto ref T t) if (from!"std.range".isInputRange!T) {
    return t.front;
}