/**
    Try utiltity that turns an exception-throwing function in to a ranged result
*/
module ddash.utils.try_;

///
@("module example")
unittest {
    import std.typecons: tuple;
    import std.algorithm: map, each;
    import ddash.utils.match: match;

    int f(int i) {
        if (i % 2 == 1) {
            throw new Exception("NOT EVEN!!!");
        }
        return i;
    }

    assert(tryUntil(f(2), f(4), f(6)).front == tuple(2, 4, 6));

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
            (const Expect.Expected _) => true,
            (const Expect.Unexpected _) => false,
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
            (Expect.Unexpected _) => Expect.Expected.init,
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

// The code below requires the fix for bugzilla issue 5710
static if (__VERSION__ < 2087L) {
    pragma(msg, __MODULE__, " not available in compiler frontend less than 2.087");
} else

/**
    tryUntil will take a number of lazy expressions and execute them in order
    until they all pass or one of them fails

    Params:
        expressions = a variadic list of expressions

    Returns:
        The result is a `Try` that either has a success value of a `Tuple` of results
        or an `Exception`

    Since:
        0.16.0
*/
auto tryUntil(T...)(lazy T expressions) {
    import std.meta: staticMap;
    import std.typecons: tuple;
    import ddash.utils.try_: Try;
    template eval(alias expression) {
        auto eval() {
            return expression();
        }
    }
    return Try!(() => staticMap!(eval, expressions).tuple);
}

///
@("tryUntil example ")
unittest {
    import std.conv: to;
    import std.algorithm: map, each;
    import std.typecons: Tuple, tuple;
    import ddash.utils.match: match;

    int f(int i) {
        if (i % 2 == 1) {
            throw new Exception("uneven int");
        }
        return i;
    }
    string g(int i) {
        if (i % 2 == 1) {
            throw new Exception("uneven string");
        }
        return i.to!string;
    }

    auto r0 = tryUntil(f(2), g(2)); // both succeed
    assert(r0.front == tuple(2, "2"));

    auto r1 = tryUntil(f(1), g(2)); // first one fails
    auto s1 = r1.match!((_) => "?", ex => ex.msg);
    assert(s1 == "uneven int");

    auto r2 = tryUntil(f(2), g(1)); // second one fails
    auto s2 = r2.match!((_) => "?", ex => ex.msg);
    assert(s2 == "uneven string");
}

@("tryUntil should not evaluate remaining expressions if one fails")
unittest {
    int[] calls;
    int f(int i) {
        calls ~= i;
        if (i % 2 == 1) {
            throw new Exception("boom");
        }
        return i;
    }

    tryUntil(f(0), f(2), f(1), f(4)).array;
    assert(calls == [0, 2, 1]);
}
