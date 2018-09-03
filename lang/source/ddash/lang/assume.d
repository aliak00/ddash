module ddash.lang.assume;

/**
    The assume template takes an alias to a funciton that casts it casts it to a different
    attribute
*/
template assume(alias fun) {
    import std.traits: FunctionAttribute, SetFunctionAttributes, functionLinkage, functionAttributes;
    private auto ref assumeAttribute(FunctionAttribute assumedAttr, T)(auto ref T t) {
        enum attrs = functionAttributes!T | assumedAttr;
        return cast(SetFunctionAttributes!(T, functionLinkage!T, attrs)) t;
    }
    private static impl(string attr) {
        return `
            enum call = "assumeAttribute!(`~attr~`)((ref Args args) { return fun(args); })(args)";
            ` ~ q{
            static assert(
                __traits(compiles, {
                    mixin(call ~ ";");
                }),
                "function " ~ fun.stringof ~ " is not callable with args " ~ Args.stringof
            );
            alias R = typeof(mixin(call));
            static if (is(R == void)) {
                mixin(call ~ ";");
            } else {
                mixin("return " ~ call ~ ";");
            }
        };
    }
    auto ref nogc_(Args...)(auto ref Args args) {
        mixin(impl("FunctionAttribute.nogc"));
    }
    auto ref pure_(Args...)(auto ref Args args) {
        mixin(impl("FunctionAttribute.pure_"));
    }
}

///
@nogc unittest {
    static b = [1];
    auto allocates() {
        return [1];
    }
    auto a = assume!allocates.nogc_();
    assert(a == b);

    auto something(int a) {
        allocates;
    }
    assume!something.nogc_(3);
}

///
unittest {
    static int thing = 0;
    alias lambda = () => thing++;
    () pure {
        cast(void)assume!lambda.pure_();
    }();
    assert(thing == 1);
}
