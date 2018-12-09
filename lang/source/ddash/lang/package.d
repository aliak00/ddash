/**
    This module contains work around for language shortcommings

$(TABLE
$(TR $(TH Module) $(TH Functions) $(TH Properties) $(TH Description))
$(TR
    $(TD $(DDOX_NAMED_REF ddash.lang.assume, `assume`))
    $(TD
        $(DDOX_NAMED_REF lang.assume.assume.nogc_, `assume!f.nogc_`)<br>
        $(DDOX_NAMED_REF lang.assume.assume.pure_, `assume!f.pure_`)<br>
        )
    $(TD)
    $(TD Casts an alias to a function to a different attribute)
    )
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
)
*/
module ddash.lang;

public  {
    import ddash.lang.capture;
    import ddash.lang.assume;
    import ddash.lang.types;
    import ddash.lang.destruct;
}
