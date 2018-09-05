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

    Executing a Try range will produce a `SumType!(T, Exception)`

    You may also call `.match` directly on the try range.

    See_Also:
        `try_`

    Since:
        0.1.0
*/
struct Try(alias fun) {
    import ddash.utils.expect;
    import ddash.lang.types: isVoid;

    bool empty = false;

    alias T = Expect!(typeof(fun()), Exception);

    private T result;

    @property T front() { return result; }

    void popFront() nothrow {
        scope(exit) empty = true;
        try {
            static if (isVoid!(T.Expected)) {
                fun();
            } else {
                result = T.expected(fun());
            }
        } catch (Exception ex) {
            result = unexpected(ex);
        }
    }

    /**
        Pass two lambdas to the match function. The first one handles the success case
        and the second one handles the failure case.

        Calling match will execute the try function if it has not already done so

        Params:
            handlers[0] = lamda that handles the success case
            handlers[1] = lambda that handles the exception

        Returns:
            Whatever the lambas return
    */
    auto match(handlers...)() {
        if (!empty) {
            popFront;
        }
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
    Type constructor for a `Try` range.
*/
template try_(alias f) {
    auto try_(Args...)(auto ref Args args) {
        return Try!(() => f(args))();
    }
}

