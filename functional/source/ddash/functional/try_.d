/**
    Functional try
*/
module ddash.functional.try_;

public import ddash.utils.try_;

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
    Creates a range expression out of a throwing functions

    See_Also:
        `ddash.utils.Try`

    Since:
        - 0.8.0
*/
template try_(alias func) {
    auto try_(Args...)(auto ref Args args) {
        return Try!(() => func(args));
    }
}

///
@("try_ general example")
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
