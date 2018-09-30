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
        return result.match!(
            (const T.Expected t) => true,
            (const T.Unexpected ex) => false,
        );
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
        return result.match!(
            (T.Expected t) => t,
            (T.Unexpected ex) => T.Expected.init,
        );
    }

    void popFront() nothrow {
        scope(exit) _empty = true;
        resolve;
    }

    /**
        Pass two lambdas to the match function. The first one handles the success case
        and the second one handles the failure case.

        Calling match will execute the try function if it has not already done so

        Params:
            handlers = lamda that handles the success case
            handlers = lambda that handles the exception

        Returns:
            Whatever the lambas return
    */
    auto match(handlers...)() {
        resolve;
        return result.match!(
            (T.Expected t) {
                static if (isVoid!(T.Expected)) {
                    return handlers[0]();
                } else {
                    return handlers[0](t);
                }
            },
            (T.Unexpected ex) {
                return handlers[1](ex);
            }
        );
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
