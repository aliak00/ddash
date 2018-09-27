/**
    General utilities

$(TABLE
$(TR $(TH Module) $(TH Functions) $(TH Properties) $(TH Description))
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.deref, `deref`))
    $(TD
        $(DDOX_NAMED_REF utils.deref.deref, `deref`)
        )
    $(TD)
    $(TD Simulates an if/else chain with expressions)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.expect, `expect`))
    $(TD
        $(DDOX_NAMED_REF utils.expect.Expected, `Expected`)<br>
        $(DDOX_NAMED_REF utils.expect.Unexpected, `Unexpected`)<br>
        $(DDOX_NAMED_REF utils.expect.expected, `expected`)<br>
        )
    $(TD)
    $(TD Used to give types to predicates with certain common functionalities)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.truthy, `truthy`))
    $(TD
        $(DDOX_NAMED_REF utils.truthy.isTruthy, `isTruthy`)<br>
        $(DDOX_NAMED_REF utils.truthy.isFalsey, `isFalsey`)<br>
        )
    $(TD)
    $(TD Call throwing functions as expressions)
    )
)
*/
module ddash.utils;

public  {
    import ddash.utils.truthy;
    import ddash.utils.deref;
    import ddash.utils.expect;
}
