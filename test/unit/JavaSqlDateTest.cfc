import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("tests of java.sql.Date with various type-validation functions", () => {
            jsd = createObject("java", "java.sql.Date").valueOf("2011-03-24")
            //jsd = createObject("java", "java.lang.String").init("17")
            [
                {function="isNumeric", f=(x) => isNumeric(x), expected=false},
                {function="isSimpleValue", f=(x) => isSimpleValue(x), expected=false},
                {function="udf", f=(x) => ((x)=>x)(x), expected=jsd},
            ].each((testCase) => {
                it("returns [#testCase.expected#] for [#testCase.function#]", () => {
                    try {
                        expect(testCase.f(jsd)).toBe(testCase.expected)
                    } catch ("TestBox.AssertionFailed" e) {
                        rethrow;
                    } catch (any e) {
                        fail("threw exception: [#e.message#] [#e.detail#] [#e.type#]")
                    }
                })
            })
        })
    }
}
