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
    bool resolved = false;

    alias T = Expect!(typeof(fun()), Exception);

    private T result;

    private void resolve() {
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
        }
    }

    @property T front() {
        resolve;
        return result;
    }

    void popFront() nothrow {
        scope(exit) empty = true;
        resolve;
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

    assert(!f0_throws.front.isExpected);
    assert( f0_nothrows.front.isExpected);
    assert(!f1_throws.front.isExpected);
    assert( f1_nothrows.front.isExpected);
}
