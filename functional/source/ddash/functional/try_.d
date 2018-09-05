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
    import ddash.lang.types: Void;
    import sumtype;

    bool empty = false;

    alias FR = typeof(fun());

    static if (is(FR == void)) {
        alias T = Void;
    } else {
        alias T = FR;
    }

    alias R = SumType!(T, Exception);

    private R result;

    @property R front() { return result; }

    void popFront() nothrow {
        scope(exit) empty = true;
        try {
            static if (is(FR == void)) {
                fun();
                result = Void();
            } else {
                result = fun();
            }
        } catch (Exception ex) {
            result = ex;
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
            (T t) {
                static if(is(T == Void)) {
                    return handlers[0]();
                } else {
                    return handlers[0](t);
                }
            },
            (Exception ex) {
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

