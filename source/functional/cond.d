/**
    Create a function that encapsulates if/else-if/else logic
*/
module functional.cond;

///
unittest {
    alias lessThanZero = (a) => a < 0;
    alias greaterOrEqualThan10 = (a) => a >= 10;
    alias identity = (a) => a;
    alias negate = (a) => -a;

    alias abs = cond!(
        a => a == 1, 42,
        2, a => a * 2,
        3, 999,
        lessThanZero, negate,
        greaterOrEqualThan10, identity,
        a => a * 100,
    );

    assert(abs(1) == 42);
    assert(abs(2) == 4);
    assert(abs(3) == 999);
    assert(abs(4) == 400);
    assert(abs(5) == 500);
    assert(abs(-3) == 3);
    assert(abs(11) == 11);
}

/**
    Takes pairs of predicates and transforms and uses the first transform that a predicate
    return true for.

    Each predicate and transform can be either an expression, or a unary function. If none
    of the predicates match, the last supplied transform will be used.

    Params:
        value = the value to evaluate

    Returns:
        Whatever is returned by the result that wins

    Benchmarks:

    A sample `cond` if/else chain was used with a mixture of expressions and unary functions and
    iterated over. A couple of hand written if/else chains were compared. The first used lambdas
    to evaluate their conditions, the second just used inline code.

    ```
    functional:     1 hnsecs
    hand written 1: 0 hnsecs
    hand written 2: 0 hnsecs
    ````
*/
template cond(statements...) {
    import std.traits: isExpressions;
    import std.functional: unaryFun;
    import utils.traits: isUnaryOver;
    static template resolve(alias f) {
        auto resolve(V...)(V values) {
            static if (isExpressions!f)
            {
                return f;
            }
            else static if (isUnaryOver!(f, V))
            {
                return f(values);
            }
            else
            {
                static assert(
                    0,
                    "Could not resolve " ~ f.stringof ~ " with values " ~ V.stringof
                );
            }
        }
    }
    auto cond(T)(T value) {
        immutable cases = statements.length / 2;
        static foreach(I; 0 .. cases)
        {{
            static if (isExpressions!(statements[I * 2]))
            {
                immutable c = statements[I * 2] == value;
            }
            else
            {
                immutable c = statements[I * 2](value);
            }
            if (c) {
                return resolve!(statements[I * 2 + 1])(value);
            }
        }}
        return resolve!(statements[$ - 1])(value);
    }
}
