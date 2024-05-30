import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("tests static functionality", () => {
            it("can't compile CFC with final static values", () => {
                var o = new test.fixtures.FinalStatic()
            })
        })
    }
}
