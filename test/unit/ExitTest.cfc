import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("tests cfexit", () => {
            it("will compile a file with cfexit in it", () => {
                o = new test.fixtures.ContainsExitStatement()
                o.f()
            })
        })
    }
}
