/**
    Functional utilities

    Functions:

$(TABLE
$(TR $(TH Module) $(TH Functions) $(TH Properties) $(TH Description))
$(TR
    $(TD $(DDOX_NAMED_REF ddash.functional.cond, `cond`))
    $(TD
        $(DDOX_NAMED_REF functional.cond.cond, `cond`)
        )
    $(TD)
    $(TD Simulates an if/else chain with expressions)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.functional.pred, `pred`))
    $(TD
        $(DDOX_NAMED_REF functional.pred.eq, `eq`)<br>
        $(DDOX_NAMED_REF functional.pred.isEq, `isEq`)<br>
        $(DDOX_NAMED_REF functional.pred.lt, `lt`)<br>
        $(DDOX_NAMED_REF functional.pred.isLt, `isLt`)<br>
        )
    $(TD)
    $(TD Used to give types to predicates with certain common functionalities)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.functional.try_, `try_`))
    $(TD
        $(DDOX_NAMED_REF functional.try_.try_, `try_`)<br>
        $(DDOX_NAMED_REF functional.try_.Try, `Try`)<br>
        )
    $(TD)
    $(TD Call throwing functions as expressions)
    )
)
*/
module ddash.functional;

public {
    import ddash.functional.cond;
    import ddash.functional.pred;
    import ddash.functional.try_;
}
