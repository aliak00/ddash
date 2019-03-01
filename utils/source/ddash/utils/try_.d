/**
    Try utiltity that turns an exception-throwing function in to a ranged result
*/
module ddash.utils.try_;

///
@("module example")
unittest {
    import std.algorithm: map, each;
    import ddash.utils.match;

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

    You may also call `ddash.utils.match` on the try range.

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
    static import ddash.utils.expect;
    import ddash.lang.types: isVoid, Void;
    import ddash.utils.optional;
    import ddash.utils.match;

    private bool _empty;
    public @property bool empty() nothrow {
        resolve;
        return _empty;
    }

    public alias Expect = ddash.utils.expect.Expect!(typeof(fun()), Exception);
    private Optional!Expect* result;

    public bool isSuccess() nothrow {
        auto value = resolve;
        return match!(
            (const Expect.Expected t) => true,
            (const Expect.Unexpected ex) => false,
        )(value);
    }

    package(ddash) Expect resolve() nothrow {
        assert(result, "result must never be null");
        if (auto value = unwrap(*result)) {
            return *value;
        }
        Expect value;
        try {
            static if (isVoid!(Expect.Expected)) {
                fun();
                value = Void();
            } else {
                value = fun();
            }
            _empty = false;
        } catch (Exception ex) {
            value = ddash.utils.expect.unexpected(ex);
            _empty = true;
        }
        *result = value;
        return value;
    }

    public @property Expect.Expected front() nothrow {
        auto value = resolve;
        return match!(
            (Expect.Expected t) => t,
            (Expect.Unexpected ex) => Expect.Expected.init,
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

@("Should convert Try to Optional")
unittest {
    import ddash.utils.optional;

    int f(int i) {
        if (i % 2 == 1) {
            throw new Exception("NOT EVEN!!!");
        }
        return i;
    }

    assert(Try!(() => f(0)).toOptional == some(0));
    assert(Try!(() => f(1)).toOptional == none);
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
