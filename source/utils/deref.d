module utils.deref;

import common: from;

ref deref(T)(T t) if (from!"std.traits".isPointer!T) {
    return *t;
}

ref deref(T)(T t) if (from!"optional".isOptional!T) {
    return t.front;
}
