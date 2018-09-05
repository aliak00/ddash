/**
    Contains useful data types that provide static information
*/
module ddash.lang.types;

/// Used in place of a void where you need storage
struct Void {}

/// True if a T is void
enum isVoid(T) = is(T == Void) || is(T == void);
