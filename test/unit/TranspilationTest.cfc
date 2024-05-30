import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("Tests Wheels stupid-arsery", () => {
            it("can't transpile CFC that has an include with a relative path", () => {
                var o = new test.fixtures.packageIssue.C()
            })
        })
    }
}
