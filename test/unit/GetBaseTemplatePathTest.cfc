import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("tests getBaseTemplatePath", () => {
            it("returns the path to the base template", () => {
                expect(getBaseTemplatePath()).toBe(expandPath("/test/runTests.cfm"))
            })
        })
    }
}
