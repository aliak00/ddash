/**
    Gets the value if valid or the other value
*/
module ddash.utils.or;

import ddash.common;
static import optional;

/**
    Retrieves the value if it is a valid value else it will retrieve the `elseValue`. Instead of
    an `elseValue`, an `elsePred` can be passed to create the value functionally

    See optiona.or for details

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
