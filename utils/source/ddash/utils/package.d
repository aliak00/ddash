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
    $(TD Derefences a "thing", could be a pointer, range, or others)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.expect, `expect`))
    $(TD
        $(DDOX_NAMED_REF utils.expect.Expected, `Expected`)<br>
        $(DDOX_NAMED_REF utils.expect.Unexpected, `Unexpected`)<br>
        $(DDOX_NAMED_REF utils.expect.expected, `expected`)<br>
        )
    $(TD)
    $(TD Represents a result that has a value or something unexpected)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.truthy, `truthy`))
    $(TD
        $(DDOX_NAMED_REF utils.truthy.isTruthy, `isTruthy`)<br>
        $(DDOX_NAMED_REF utils.truthy.isFalsey, `isFalsey`)<br>
        )
    $(TD)
    $(TD Represents "truthiness")
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.or, `or`))
    $(TD
        $(DDOX_NAMED_REF utils.or.or, `or`)
        )
    $(TD)
    $(TD Null coallescing operator, but works on other ranges and other types as well)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.slice, `slice`))
    $(TD
        $(DDOX_NAMED_REF utils.slice.slice, `slice`)
        )
    $(TD)
    $(TD Slices arrays, ranges, and PODs)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.optional, `optional`))
    $(TD)
    $(TD)
    $(TD Imports a subset of https://optional.dub.pm)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.match, `match`))
    $(TD
        $(DDOX_NAMED_REF utils.match.match, `match`)
        )
    $(TD)
    $(TD matches on expects, trys, and optionals)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.try_, `try_`))
    $(TD
        $(DDOX_NAMED_REF ddash.utils.try_.Try, `Try`)<br>
        $(DDOX_NAMED_REF ddash.utils.try_.tryUntil, `tryUntil`)<br>
        )
    $(TD)
    $(TD utilities to deal with throwing functions)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.utils.flag, `Flag`))
    $(TD
        $(DDOX_NAMED_REF utils.flag.Flag, `Flag`)
        )
    $(TD)
    $(TD better than std.typecons.Flag)
    )
)
*/
module ddash.utils;

public  {
    import ddash.utils.truthy;
    import ddash.utils.deref;
    import ddash.utils.expect;
    import ddash.utils.or;
    import ddash.utils.slice;
    import ddash.utils.optional;
    import ddash.utils.match;
    import ddash.utils.try_;
    import ddash.utils.flag;
}
