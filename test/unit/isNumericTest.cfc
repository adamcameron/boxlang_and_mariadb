import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("tests of isNumeric with various input types", () => {
            [
                {type="non-numeric string", value="non-numeric string", expected=false},
                {type="true", value=true, expected=true},
                {type="false", value=false, expected=true},
                {type="Yes", value="Yes", expected=true},
                {type="No", value="No", expected=true},
                {type="integer string", value="17", expected=true},
                {type="float string", value="1.7", expected=true},
                {type="array", value=[17], expected=false},
                {type="struct", value={"17"=17}, expected=false},
                {type="ordered struct", value=["17"=17], expected=false},
                {type="query", value=queryNew("17"), expected=false},
                {type="datetime", value=now(), expected=false},
                {type="xml", value=xmlParse("<aaa/>"), expected=false},
                {type="null", value=(()=>{})(), expected=false},
                {type="function", value=()=>{}, expected=false},
                {type="CFC instance", value=new BaseSpec(), expected=false},
                {type="java Integer", value=createObject("java", "java.lang.Integer").init(17), expected=true},
                {type="java Float", value=createObject("java", "java.lang.Float").init(1.7), expected=true},
                {type="java Long", value=createObject("java", "java.lang.Long").init(17), expected=true},
                {type="java Double", value=createObject("java", "java.lang.Double").init(1.7), expected=true},
                {type="java BigDecimal", value=createObject("java", "java.math.BigDecimal").init(1.7), expected=true},
                {type="java StringBuilder", value=createObject("java", "java.lang.StringBuilder").init(17), expected=false},
                {type="java.sql.Date", value=createObject("java", "java.sql.Date").valueOf("2011-03-24"), expected=false}, // errors
            ].each((testCase) => {
                it("returns [#testCase.expected#] for [#testCase.type#]", () => {
                    try {
                        expect(isNumeric(testCase.value)).toBe(testCase.expected)
                    } catch ("TestBox.AssertionFailed" e) {
                        rethrow;
                    } catch (any e) {
                        fail("threw exception: [#e.message#] [#e.detail#]")
                    }
                })
            })
        })
    }
}
