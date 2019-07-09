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
    $(TD $(DDOX_NAMED_REF ddash.functional.trybind, `trybind`))
    $(TD
        $(DDOX_NAMED_REF functional.tryBind.tryBind, `tryBind`)<br>
        )
    $(TD)
    $(TD Create an bind expression out of a throwing function)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.functional.bind, `bind`))
    $(TD
        $(DDOX_NAMED_REF functional.bind.bind, `bind`)
        )
    $(TD)
    $(TD Call binds parameters to functions)
    )
)
*/
module ddash.functional;

public {
    import ddash.functional.cond;
    import ddash.functional.pred;
    import ddash.functional.trybind;
    import ddash.functional.bind;
}
