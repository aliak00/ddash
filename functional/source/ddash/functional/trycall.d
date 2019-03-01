/**
    Functional try
*/
module ddash.functional.trycall;

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
        .map!(tryCall!f)
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
    Creates a range expression out of a throwing functions

    See_Also:
        `ddash.utils.Try`

    Since:
        - 0.8.0
*/
template tryCall(alias func) {
    auto tryCall(Args...)(auto ref Args args) {
        import ddash.utils.try_;
        return Try!(() => func(args));
    }
}

///
@("tryCall general example")
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

    auto f0_throws = tryCall!f0(Yes.throws);
    auto f0_nothrows = tryCall!f0(No.throws);

    auto f1_throws = tryCall!f1(Yes.throws);
    auto f1_nothrows = tryCall!f1(No.throws);

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
