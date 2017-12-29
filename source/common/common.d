module common;

public template from(string moduleName) {
    mixin("import from = " ~ moduleName ~ ";");
}
