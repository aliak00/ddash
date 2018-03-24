/**
    Contains range utilities

Functions:

$(TABLE
$(TR $(TH Module) $(TH Functions) $(TH Properties) $(TH Description))
$(TR
    $(TD `range.front`)
    $(TD
        $(DDOX_NAMED_REF range.front.frontOr, `frontOr`)<br>
        $(DDOX_NAMED_REF range.front.withFront, `withFront`)<br>
        $(DDOX_NAMED_REF range.front.maybeFront, `maybeFront`)<br>
        )
    $(TD)
    $(TD Operates on the front of a range.)
    )
$(TR
    $(TD `range.back`)
    $(TD
        $(DDOX_NAMED_REF range.back.backOr, `backOr`)<br>
        $(DDOX_NAMED_REF range.back.withBack, `withBack`)<br>
        $(DDOX_NAMED_REF range.back.maybeBack, `maybeBack`)<br>
        )
    $(TD)
    $(TD Operated on the back of a range.)
    )
)
*/
module range;

public {
    import range.front;
    import range.back;
}
