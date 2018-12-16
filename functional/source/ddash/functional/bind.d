/**
    Takes a function and binds arguments to it
*/
module ddash.functional.bind;

import ddash.common;

/**
    Allows you to bind arguments to a function at different positions

    E.g. bind arguments to the 1st and 3rd parameter and call:
    ---
    void f(int a, int b, int c) {}
    alias a = bind!(f, 1, void, 3);
    alias b = (int second) => f(1, second, 3);

    a(2); // calls f(1, 2, 3);
    b(2); // calls f(1, 2, 3);
    ---

    Params:
        pred = the predicate to bind arguments to
        BoundArgs = the arguments to bind. Use `void` to leave an argument slot open

    See_Also:
        `std.functional.partial`

    Since:
        0.9.0
*/
template bind(alias pred, BoundArgs...) {
    auto bind(PassedArgs...)(auto ref PassedArgs passedArgs) {
        string generateCall() {
            import std.conv: to;
            string ret = "pred(";
            int passedArgsIndex = 0;
            static foreach (i, ba; BoundArgs) {
            	static if (is(ba == void)) {
                    ret ~= "passedArgs[" ~ passedArgsIndex.to!string ~ "],";
                    passedArgsIndex++;
                } else {
                    ret ~= "BoundArgs[" ~ i.to!string ~ "],";
                }
            }
            foreach (i; passedArgsIndex .. passedArgs.length) {
                ret ~= "passedArgs[" ~ i.to!string ~ "],";
            }
            return ret ~ ")";
        }

        import ddash.common.ctstrings;

        static assert(
            __traits(compiles, mixin(generateCall)),
            "Cannot call predicate with bound arguments '" ~ CTStrings!BoundArgs ~ "' and given arguments of '" ~ CTStrings!PassedArgs ~ "'",
        );

        return mixin(generateCall);
    }
}

///
unittest {
    auto f0(int a, int b, int c) {
        return a * b + c;
    }

    assert(bind!(f0, 2, 3, 4)() == 10);
    assert(bind!(f0, 2, void, 4)(3) == 10);
    assert(bind!(f0, 2, void, void)(3, 4) == 10);
    assert(bind!(f0, void, void, void)(2, 3, 4) == 10);
    assert(bind!(f0, void, void, 4)(2, 3) == 10);
    assert(bind!(f0, void, 3, 4)(2) == 10);
}
