/**
    Contains useful data types that provide static information
*/
module ddash.lang.types;

/**
    Used in place of a void where you need storage

    Since:
        - 0.0.1
*/
struct Void {}

/**
    True if a T is `Void`

    Since:
        - 0.0.1
*/
enum isVoid(T) = is(T == Void) || is(T == void);
