/**
    Allows for functions with named argument
*/
module ddash.lang.arg;

/**
    This struct is used to pass an argument to a function that takes an `Arg!T` as a parameter.

    E.g.:
    ---
    void fun(Arg!int.a a) {}
    fun(arg.a = 7);
    ---

    Since:
        0.9.0

    See_Also:
        - https://forum.dlang.org/post/ejnsqqebrjbwefjhagvg@forum.dlang.org
*/
struct arg {
    private struct Name(string name) {
        public static auto opAssign(T)(auto ref T value) {
            return Arg!T.Arg!name(value);
        }
    }
    template opDispatch(string name) {
        alias opDispatch = Name!name;
    }
}

/**
    This struct is used to to specify that a function takes a named argument

    E.g.:
    ---
    void fun(Arg!int.a a) {}
    fun(arg.a = 7);
    ---

    Since:
        0.9.0

    See_Also:
        - https://forum.dlang.org/post/ejnsqqebrjbwefjhagvg@forum.dlang.org
*/
struct Arg(T) {
    private struct Arg(string name) {
        this(T value) {
            import std.algorithm: move;
            this.value = value.move;
        }
        public T value;
        alias value this;
    }
    template opDispatch(string name) {
        alias opDispatch = Arg!name;
    }
}

///
@("allows passing of correct type")
unittest {
    int add(Arg!int.a a, Arg!int.b b) {
        return a + b;
    }
    assert(add(arg.a = 3, arg.b = 4) == 7);
}
