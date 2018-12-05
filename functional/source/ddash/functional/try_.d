/**
    Functional try
*/
module ddash.functional.try_;

///
unittest {
    import std.algorithm: map, each;

    auto arr = [1, 2, 3];

    int f(int i) {
        if (i % 2 == 1) {
            throw new Exception("NOT EVEN!!!");
        }
        return i;
    }

    auto result = arr
        .map!(try_!f)
        .map!(r => r
            .match!(
                (int _) => "even",
                (Exception _) => "odd"
            )
        );

    assert(result.equal(["odd", "even", "odd"]));
}

import ddash.common;

/**
    Creates a Try range out of an alias to a function that could throw.

    Calling any range functions on a try range will resolve the delegate and produce
    a `front` range value if ther function did not throw.

    You may also call `.match` directly on the try range.

    See_Also:
        `try_`

    Since:
        0.0.1
*/
struct Try(alias fun) {
    import ddash.utils.expect;
    import ddash.lang.types: isVoid;
    alias expectmatch = ddash.utils.expect.match;

    private bool _empty;
    @property bool empty() nothrow {
        resolve;
        return _empty;
    }

    bool resolved = false;

    alias T = Expect!(typeof(fun()), Exception);

    private T result;

    bool isSuccess() nothrow {
        resolve;
        return expectmatch!(
            (const T.Expected t) => true,
            (const T.Unexpected ex) => false,
        )(result);
    }

    private void resolve() nothrow {
        if (resolved) {
            return;
        }
        scope(exit) resolved = true;
        try {
            static if (isVoid!(T.Expected)) {
                fun();
            } else {
                result = T.expected(fun());
            }
        } catch (Exception ex) {
            result = unexpected(ex);
            _empty = true;
        }
    }

    @property T.Expected front() nothrow {
        resolve;
        return expectmatch!(
            (T.Expected t) => t,
            (T.Unexpected ex) => T.Expected.init,
        )(result);
    }

    void popFront() nothrow {
        scope(exit) _empty = true;
        resolve;
    }
}

/**
    Evaluates to true if `T` is a `Try` type
*/
template isTry(T) {
    import std.traits: isInstanceOf;
    enum isTry = isInstanceOf!(Try, T);
}

/**
    Pass two lambdas to the match function. The first one handles the success case
    and the second one handles the failure case.

    Calling match will execute the try function if it has not already done so

    Params:
        tryInstance = lamda that handles the success case
        handlers = lambda that handles the exception

    Returns:
        Whatever the lambas return
*/
template match(handlers...) {
    auto match(T)(T tryInstance) if (isTry!T) {
        import ddash.lang.types: isVoid;
        import ddash.utils.expect;
        tryInstance.resolve;
        static if (isVoid!(T.T.Expected)) {
            alias success = (t) => handlers[0]();
        } else {
            alias success = (t) => handlers[0](t);
        }
        return ddash.utils.expect.match!(
            (ref T.T.Expected t) => success(t),
            (ref T.T.Unexpected ex) => handlers[1](ex),
        )(tryInstance.result);
    }
}

/**
    Creates a range expression out of a throwing functions

    Since:
        - 0.0.1
*/
template try_(alias func) {
    auto try_(Args...)(auto ref Args args) {
        return Try!(() => func(args))();
    }
}

///
unittest {
    import std.typecons: Flag;

    void f0(Flag!"throws" throws) {
        if (throws) {
            throw new Exception("f0");
        }
    }
    int f1(Flag!"throws" throws) {
        if (throws) {
            throw new Exception("f1");
        }
        return 0;
    }

    auto f0_throws = try_!f0(Yes.throws);
    auto f0_nothrows = try_!f0(No.throws);

    auto f1_throws = try_!f1(Yes.throws);
    auto f1_nothrows = try_!f1(No.throws);

    auto g() {
        try {
            throw new Exception("hahah");
        } catch (Exception ex) {
            return ex;
        }
    }

    assert(!f0_throws.isSuccess);
    assert( f0_nothrows.isSuccess);
    assert(!f1_throws.isSuccess);
    assert( f1_nothrows.isSuccess);
}


unittest {
    // Test that accesses context frames from outside the match function
    int i;
    int odd(int ii) {
        i = ii;
        if (i % 2 == 0)
            throw new Exception("boo");
        return ii;
    }

    auto g0 = () @trusted { return "g0"; } ();

    auto a = try_!odd(1).match!(
        (int v) => g0,
        (Exception ex) => ex.msg,
    );

    auto b = try_!odd(2).match!(
        (int v) => g0,
        (Exception ex) => ex.msg,
    );

    assert(a == "g0");
    assert(b == "boo");
}
