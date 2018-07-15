/**
    Contains range utilities

Functions:

$(TABLE
$(TR $(TH Module) $(TH Functions) $(TH Properties) $(TH Description))
$(TR
    $(TD $(DDOX_NAMED_REF ddash.range.chunk, `chunk`))
    $(TD
        $(DDOX_NAMED_REF range.chunk.chunk, `chunk`)
        )
    $(TD)
    $(TD Creates an array of elements split into groups the length of size.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.range.drop, `drop`))
    $(TD
        $(DDOX_NAMED_REF range.drop.drop, `drop`)<br>
        $(DDOX_NAMED_REF range.drop.dropRight, `dropRight`)<br>
        $(DDOX_NAMED_REF range.drop.dropWhile, `dropWhile`)<br>
        $(DDOX_NAMED_REF range.drop.dropRightWhile, `dropRightWhile`)<br>
        )
    $(TD)
    $(TD Drops elements from a range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.range.front, `front`))
    $(TD
        $(DDOX_NAMED_REF range.front.frontOr, `frontOr`)<br>
        $(DDOX_NAMED_REF range.front.withFront, `withFront`)<br>
        $(DDOX_NAMED_REF range.front.maybeFront, `maybeFront`)<br>
        )
    $(TD)
    $(TD Operates on the front of a range.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.range.back, `back`))
    $(TD
        $(DDOX_NAMED_REF range.back.backOr, `backOr`)<br>
        $(DDOX_NAMED_REF range.back.withBack, `withBack`)<br>
        $(DDOX_NAMED_REF range.back.maybeBack, `maybeBack`)<br>
        )
    $(TD)
    $(TD Operated on the back of a range.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.range.nth, `nth`))
    $(TD
        $(DDOX_NAMED_REF range.nth.nth, `nth`)<br>
        $(DDOX_NAMED_REF range.nth.first, `first`)<br>
        $(DDOX_NAMED_REF range.nth.last, `last`)<br>
    )
    $(TD)
    $(TD Returns the element at nth index of range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.range.slicing, `slicing`))
    $(TD
        $(DDOX_NAMED_REF range.slicing.slice, `slice`)<br>
        $(DDOX_NAMED_REF range.slicing.tail, `tail`)<br>
        $(DDOX_NAMED_REF range.slicing.initial, `initial`)<br>
    )
    $(TD)
    $(TD Creates a slice of a range)
    )
)
*/
module ddash.range;

public {
    import ddash.range.chunk;
    import ddash.range.drop;
    import ddash.range.front;
    import ddash.range.back;
    import ddash.range.nth;
    import ddash.range.slicing;
}
