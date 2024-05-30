import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("Tests package functionality", () => {
            it("can't compile CFC with a package method", () => {
                //var o = new test.fixtures.PackageMethod()

                include "/experimentation/edd/functions.cfm"
            })
        })
    }
}
