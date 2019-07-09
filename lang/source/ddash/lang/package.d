/**
    This module contains work around for language shortcommings

$(TABLE
$(TR $(TH Module) $(TH Functions) $(TH Properties) $(TH Description))
$(TR
    $(TD $(DDOX_NAMED_REF ddash.lang.capture, `capture`))
    $(TD
        $(DDOX_NAMED_REF lang.capture.capture, `capture`)<br>
        $(DDOX_NAMED_REF lang.capture.unpack, `unpack`)<br>
        )
    $(TD)
    $(TD Captures variables to be passed through in to lamdas to avoid allocation)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.lang.destruct, `destruct`))
    $(TD
        $(DDOX_NAMED_REF lang.destruct.destructInto, `destructInto`)
        )
    $(TD)
    $(TD Destructures objects in to variables.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.lang.types, `types`))
    $(TD
        $(DDOX_NAMED_REF lang.types.Void, `Void`)
        )
    $(TD)
    $(TD Utility types)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.lang.string, `string`))
    $(TD
        $(DDOX_NAMED_REF lang.string.multiline, `multiline`)<br>
        $(DDOX_NAMED_REF lang.string.singleline, `singleline`)<br>
        )
    $(TD)
    $(TD String utilities)
    )
$(TR
    $(TD $(DDOX_NAMED_REF ddash.lang.from, `from`))
    $(TD
        $(DDOX_NAMED_REF lang.from.from, `from`)<br>
        )
    $(TD)
    $(TD Implementation of D import idiom)
    )
)
*/
module ddash.lang;

public  {
    import ddash.lang.capture;
    import ddash.lang.types;
    import ddash.lang.destruct;
    import ddash.lang.string;
    import ddash.lang.from;
    import ddash.lang.range;
    import ddash.lang.headmutable;
}
