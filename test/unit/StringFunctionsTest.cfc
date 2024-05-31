import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("Tests string functions", () => {
            it("fails to extract the middle of a string", () => {
                expect(mid("1234567890", 2, 9)).toBe("234567890")
            })
            it("fails to do a case-conversion regex replacement", () => {
                expect("zachary".reReplace("^(.)(.*)$", "\u\1\2")).toBe("Zachary")
            })
        })
    }
}
