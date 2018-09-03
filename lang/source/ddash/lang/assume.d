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
    auto ref nogc_(Args...)(auto ref Args args) {
        enum call = "assumeAttribute!(FunctionAttribute.nogc)((ref Args args) { fun(args); })(args)";
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
            return mixin(call ~ ";");
        }
    }
}

///
@nogc unittest {
    auto allocates() {
        return [1];
    }
    assume!allocates.nogc_();

    auto something(int a) {
        allocates;
    }
    assume!something.nogc_(3);
}
