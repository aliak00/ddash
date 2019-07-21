module ddash.utils.errors;

/**
    An exception that's throw by `orElseThrow` should the exception maker throw
*/
public class OrElseThrowException : Exception {
    /// Original cause of this exception
    Exception cause;

    package(ddash.utils) this(Exception cause) @safe nothrow pure {
        super(cause.msg);
        this.cause = cause;
    }
}
