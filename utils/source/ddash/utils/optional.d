/**
    Just imports the needed symbols from the optional package on code.dlang.

    Since ddash has it's own `match` function it's recommended to import
    `optional` via `ddash.utils.optional` so that you don't have to go through
    renaming/aliasing optiona's match function against ddash's match functions
*/
module ddash.utils.optional;

public import optional:
    Optional,
    toOptional,
    some,
    none,
    no,
    isOptional,
    toNullable,
    oc
    ;
