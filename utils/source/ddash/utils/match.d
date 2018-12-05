module ddash.utils.match;

import ddash.common;

/**
    The match template works by taking a number of `handlers`, one of which is applies
    if there's a match on the object that `match` is called on.

    Since:
        0.0.8
*/
template match(handlers...) {
    alias match = from!"ddash.utils.expect".match!handlers;
    alias match = from!"ddash.functional.try_".match!handlers;
}

///
unittest {
    import ddash.utils.expect;
    import std.meta: AliasSeq;
    alias T = Expect!(int, int);
    alias handlers = AliasSeq!(
        (T.Expected _) => "yo",
        (T.Unexpected _) => "ho"
    );
    assert(T.expected(0).match!handlers == "yo");
    assert(T.unexpected(0).match!handlers == "ho");
}

///
unittest {
    import ddash.functional.try_;
    int f(int i) {
        if (i % 2 == 1) {
            throw new Exception("NOT EVEN!!!");
        }
        return i;
    }
    import std.meta: AliasSeq;
    alias handlers = AliasSeq!(
        (int _) => "even",
        (Exception _) => "odd"
    );
    auto a = Try!(() => f(2))().match!handlers;
    auto b = Try!(() => f(1))().match!handlers;

    assert(a == "even");
    assert(b == "odd");
}
