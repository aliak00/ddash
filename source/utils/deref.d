module utils.deref;

import std.traits: isPointer;
import optional: isOptional;

ref deref(T)(T t) if (isPointer!T) {
    return *t;
}

ref deref(T)(T t) if (isOptional!T) {
    return t.front;
}
