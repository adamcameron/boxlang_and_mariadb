import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("tests higher oder functions", () => {
            it("supports reduceRight", () => {
                expect([1,2,3,4].reduceRight((s, v) => "#s##v#", "")).toBe("4321")
            })
            it("supports reduceRight via function", () => {
                expect([1,2,3,4].reduceRight(function (s, v) {
                    return "#s##v#"
                }, "")).toBe("4321")
            })
        })
    }
}
