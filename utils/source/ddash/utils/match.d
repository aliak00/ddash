/**
    Matches on types that could be deconstructible
*/
module ddash.utils.match;

import ddash.common;
/**
    Tries to match handlers by deconstructing a type if it's deconstructable, and calling the appropriate
    handler for the deconstructed value

    The currently supported deconstructible types are:
    <li> Optional types
    <li> Expect types
    <li> Try types

    See example for usage details

    Params:
        handlers = lambdas to the type handlers.
*/
template match(handlers...) {

    import ddash.utils.expect: Expect, isExpect;
    import ddash.utils.optional: Optional, isOptional;
    import ddash.utils.try_: isTry;

    auto match(T, E)(auto ref Expect!(T, E) expect) {
        static import sumtype;
        return sumtype.match!handlers(expect.data);
    }

    auto match(T)(auto ref T tryInstance) if (isTry!T) {
        import ddash.lang.types: isVoid;
        import ddash.utils.expect;
        auto value = tryInstance.resolve;
        static if (isVoid!(T.Expect.Expected)) {
            alias success = (t) => handlers[0]();
        } else {
            alias success = (t) => handlers[0](t);
        }
        return .match!(
            (ref T.Expect.Expected t) => success(t),
            (ref T.Expect.Unexpected ex) => handlers[1](ex),
        )(value);
    }

    auto match(T)(auto ref Optional!T opt) {
        import optional: match;
        return match!handlers(opt);
    }

    // auto match(T)(auto ref T value) if (!isOptional!T && !isTry!T && !isExpect!T) {
    //     import sumtype: SumType, match;
    //     return SumType!T(value).match!handlers;
    // }
}

///
@("match on Try, Expect, and Optional")
unittest {
    import ddash.utils.optional;
    import ddash.utils.expect;
    import ddash.utils.try_;

    auto a = Try!(() => 3).match!(
        (int) => true,
        (Exception) => false,
    );

    auto b = Expect!(int, int)(3).match!(
        (int) => true,
        (Unexpected!int) => false,
    );

    auto c = some(3).match!(
        (int) => true,
        () => false,
    );

    assert(a);
    assert(b);
    assert(c);
}

@("expect.match should work")
unittest {
    import ddash.utils.expect;

    Expect!(int, string) even(int i) @nogc {
        if (i % 2 == 0) {
            return typeof(return).expected(i);
        } else {
            return typeof(return).unexpected("not even");
        }
    }

    import std.meta: AliasSeq;

    alias handlers = AliasSeq!(
        (int n) => n,
        (Unexpected!string str) => -1,
    );

    auto a = even(1).match!handlers;
    auto b = even(2).match!handlers;

    assert(a == -1);
    assert(b == 2);
}

@("try.match handles inner context frames")
unittest {
    import ddash.utils.try_;
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

// @("match on random types")
// unittest {
//     static struct Blah {
//         int x; int y;
//     }

//     int a;

//     auto r0 = a.match!(
//         (string a) => false,
//         (int a) => true,
//         (float a) => false
//     );

//     assert(r0);
// }
