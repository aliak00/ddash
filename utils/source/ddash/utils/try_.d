/**
    Try utiltity that turns an exception-throwing function in to a ranged result
*/
module ddash.utils.try_;

///
@("module example")
unittest {
    import std.algorithm: map, each;

    int f(int i) {
        if (i % 2 == 1) {
            throw new Exception("NOT EVEN!!!");
        }
        return i;
    }

    auto result = [1, 2, 3]
        .map!(a => Try!(() => f(a)))
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
    a `front` range value if the function did not throw.

    You may also call `.match` directly on the try range.

    See_Also:
        `ddash.functional.try_`

    Since:
        0.8.0
*/
auto Try(alias fun)() {
    auto a = TryImpl!fun();
    a.result = new typeof(*a.result);
    return a;
}

/**
    The implementation of the `Try` that's returned by the type constructor
*/
private struct TryImpl(alias fun) {
    import ddash.utils.expect;
    import ddash.lang.types: isVoid, Void;
    import optional;

    private alias expectmatch = ddash.utils.expect.match;

    private bool _empty;
    public @property bool empty() nothrow {
        resolve;
        return _empty;
    }

    private alias T = Expect!(typeof(fun()), Exception);
    private Optional!T* result;

    public bool isSuccess() nothrow {
        auto value = resolve;
        return expectmatch!(
            (const T.Expected t) => true,
            (const T.Unexpected ex) => false,
        )(value);
    }

    private T resolve() nothrow {
        assert(result, "result must never be null");
        if (auto value = unwrap(*result)) {
            return *value;
        }
        T value;
        try {
            static if (isVoid!(T.Expected)) {
                fun();
                value = T.expected(Void());
            } else {
                value = T.expected(fun());
            }
            _empty = false;
        } catch (Exception ex) {
            value = unexpected(ex);
            _empty = true;
        }
        *result = value;
        return value;
    }

    public @property T.Expected front() nothrow {
        auto value = resolve;
        return expectmatch!(
            (T.Expected t) => t,
            (T.Unexpected ex) => T.Expected.init,
        )(value);
    }

    public size_t length() {
        resolve;
        return !_empty ? 1 : 0;
    }

    public void popFront() nothrow {
        resolve;
        _empty = true;
    }
}

/**
    Evaluates to true if `T` is a `Try` type

    Since:
        0.0.8
*/
template isTry(T) {
    import std.traits: isInstanceOf;
    enum isTry = isInstanceOf!(TryImpl, T);
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

    Since:
        0.0.8
*/
template match(handlers...) {
    auto match(T)(auto ref T tryInstance) if (isTry!T) {
        import ddash.lang.types: isVoid;
        import ddash.utils.expect;
        auto value = tryInstance.resolve;
        static if (isVoid!(T.T.Expected)) {
            alias success = (t) => handlers[0]();
        } else {
            alias success = (t) => handlers[0](t);
        }
        return ddash.utils.expect.match!(
            (ref T.T.Expected t) => success(t),
            (ref T.T.Unexpected ex) => handlers[1](ex),
        )(value);
    }
}

@("Should convert Try to Optional")
unittest {
    import optional;

    int f(int i) {
        if (i % 2 == 1) {
            throw new Exception("NOT EVEN!!!");
        }
        return i;
    }

    assert(Try!(() => f(0)).toOptional == some(0));
    assert(Try!(() => f(1)).toOptional == none);
}

@("handles inner context frames")
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

    import std.meta: AliasSeq;
    alias handlers = AliasSeq!(
        (int v) => g0,
        (Exception ex) => ex.msg,
    );

    auto a = Try!(() => odd(1)).match!handlers;
    auto b = Try!(() => odd(2)).match!handlers;

    assert(a == "g0");
    assert(b == "boo");
}

@("should not call lambda more than once when copied around")
unittest {
    int count;
    int func() {
        return count++;
    }

    auto a = Try!func;
    auto b = a;
    auto x = a.front;
    auto y = b.front;
    while (!b.empty) b.popFront;
    assert(x == 0);
    assert(y == 0);
    assert(count == 1);
}
