module ddash.lang.headmutable;

import std.traits;
import std.typecons: rebindable;

/**
    Provides conversion to the head-mutable version for certain built-in
    types. If called on a non built-in type that that implements `opHeadMutable`
    then this will simply forward to the member function
*/
public auto ref opHeadMutable(T)(auto ref T value) @safe nothrow pure {
    static if (isMutable!T) {
        // If it's already mutable just forward along.
        return value;
    } else static if (isPointer!T) {
        // T is a pointer, and decays naturally.
        return value;
    } else static if (isDynamicArray!T) {
        // T is a dynamic array, and decays naturally.
        return value;
    } else static if (!hasAliasing!(Unqual!T)) {
        // T is a POD datatype - either a built-in type, or a struct with only POD members.
        return cast(Unqual!T)value;
    } else static if (is(T == class) || is(T == interface)) {
        // Classes are reference types, so only the reference to it may be made head-mutable.
        return rebindable(value);
    } else static if (isAssociativeArray!T) {
        // AAs are reference types, so only the reference to it may be made head-mutable.
        return rebindable(value);
    } else static if (hasMember!(T, "opHeadMutable")) {
        // Incase called as non-ufcs free function, and the type has an opHeadMutable
        return value.opHeadMutable;
    } else {
        static assert(false, "Type " ~ T.stringof ~ " cannot be made head-mutable.");
    }
}

/**
    Gives you the head mutable type of `T` if `T` implements `opHeadMutable`
*/
public alias HeadMutable(T) = typeof(T.init.opHeadMutable());

/**
    Creates that type that results in copying over the type qualifiers of `ConstSource` to `T`.
*/
public alias HeadMutableOf(T, ConstSource) = HeadMutable!(CopyTypeQualifiers!(ConstSource, T));

unittest {
    static struct S {
        int opHeadMutable() { return 0; }
    }
    static assert(is(HeadMutable!S == int));
}
