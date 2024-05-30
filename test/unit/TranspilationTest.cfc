import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("Tests Wheels stupid-arsery", () => {
            it("can't transpile CFC made via includes", () => {
                var o = new test.fixtures.packageIssue.C()

                writeDump(getMetaData(o))
            })
        })
    }
}
