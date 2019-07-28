/**
    Matches on types that could be deconstructible
*/
module ddash.utils.match;

import ddash.common;

/**
    Tries to match handlers by deconstructing a type if it's deconstructable, and calling the appropriate
    handler for the deconstructed value. If it's not a deconstructible type then it just tries a first match

    Hooks:
        `hookMatch`: if a type has this hook then it will be passed the handlers and whatever it returns
        will be the return value

    Params:
        handlers = lambdas to the type handlers.

    Since:
        - 0.12.0
*/
template match(handlers...) {
    auto ref match(T)(auto ref T value) {
        static if (from.std.traits.hasMember!(T, "hookMatch")) {
            return value.hookMatch!handlers;
        } else static if (from.ddash.utils.isOptional!T) {
            static import optional;
            return optional.match!handlers(value);
        } else {
            import sumtype: canMatch;
            size_t handlerIndex() pure {
                size_t result = size_t.max;
                static foreach (hid, handler; handlers) {
                    static if (canMatch!(handler, T)) {
                        if (result == size_t.max) {
                            result = hid;
                        }
                    }
                }
                return result;
            }
            static assert(
                handlerIndex != size_t.max,
                "Type " ~ T.stringof ~ " cannot be matched on."
            );
            return handlers[handlerIndex](value);
        }
    }
}

///
@("match on Try, Expect, and Optional")
unittest {
    import ddash.utils: Try, some, Expect, Unexpected;

    const a = Try!(() => 3).match!(
        (int) => true,
        (Exception) => false,
    );

    const b = Expect!(int, int)(3).match!(
        (int) => true,
        (Unexpected!int) => false,
    );

    const c = some(3).match!(
        (int) => true,
        () => false,
    );

    assert(a);
    assert(b);
    assert(c);
}

@("expect.match should work")
unittest {
    import std.meta: AliasSeq;
    import ddash.utils: Expect, Unexpected;

    Expect!(int, string) even(int i) @nogc {
        if (i % 2 == 0) {
            return typeof(return).expected(i);
        } else {
            return typeof(return).unexpected("not even");
        }
    }

    alias handlers = AliasSeq!(
        (int n) => n,
        (Unexpected!string _) => -1,
    );

    const a = even(1).match!handlers;
    const b = even(2).match!handlers;

    assert(a == -1);
    assert(b == 2);
}

@("try.match handles inner context frames")
unittest {
    import ddash.utils: Try;
    // Test that accesses context frames from outside the match function
    int i;
    int odd(int ii) {
        i = ii;
        if (i % 2 == 0)
            throw new Exception("boo");
        return ii;
    }

    const g0 = () @trusted { return "g0"; } ();

    import std.meta: AliasSeq;
    alias handlers = AliasSeq!(
        (int _) => g0,
        (Exception ex) => ex.msg,
    );

    const a = Try!(() => odd(1)).match!handlers;
    const b = Try!(() => odd(2)).match!handlers;

    assert(a == "g0");
    assert(b == "boo");
}

@("match on random types")
unittest {
    static struct Foo {
        int x; int y;
    }

    static struct Bar {
        int a; int b;
    }

    const r0 = 3.match!(
        (string a) => false,
        (int a) => true,
        (int a) => false
    );

    assert(r0);

    const r1 = Foo().match!(
        (a) => a.a + 10,
        (a) => a.x + 1,
        (int _) => 10,
    );

    assert(r1 == 1);
}
