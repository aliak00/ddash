/**
    Gets the value if valid or the other value
*/
module ddash.utils.or;

import ddash.common;
static import optional;

/**
    Retrieves the value if it is a valid value else it will retrieve the `elseValue`. Instead of
    an `elseValue`, an `elsePred` can be passed to create the value functionally

    Params:
        value = the value to resolve
        elseValue = the value to get if `value` cannot be resolved
        elsePred = the perdicate to call if `value` cannot be resolved

    Returns:
        $(LI If `value` is nullable and null, then it will return the `elseValue`, else `value`)
        $(LI If `value` is typecons.Nullable and isNull, then it will return the `elseValue`, else `value`)
        $(LI If `value` is a range and empty, and `elseValue` is a compatible range,
            then `elseValue` range will be returned, else `value`)
        $(LI If `value` is a range and empty, and `elseValue` is an `ElementType!Range`,
            then `elseValue` will be returned, else `value.front`)

    Since:
        - 0.0.2
*/
alias or = optional.or;

///
@("works with lambdas")
unittest {
    // Get or ranges
    assert((int[]).init.or([1, 2, 3]).equal([1, 2, 3]));
    assert(([789]).or([1, 2, 3]).equal([789]));

    // Lambdas
    assert(([789]).or!(() => [1, 2, 3]).equal([789]));
}
