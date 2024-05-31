import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("Repro cases for exception-oriented bugs", () => {
            it("returns useful in the exception message (fails)", () => {
                var myDate = createObject("java", "java.sql.Date").valueOf("2011-03-24")

                try {
                    isNumeric(myDate)
                } catch (any e) {
                    expect(e.message).notToBeNull()
                }
            })
            it("returns useful in the exception detail (fails)", () => {
                var myDate = createObject("java", "java.sql.Date").valueOf("2011-03-24")

                try {
                    isNumeric(myDate)
                } catch (any e) {
                    expect(e.detail).notToBeNull()
                    expect(e.detail).notToBeEmpty()
                }
            })

            it("is a control with a CFML exception (passes)", () => {
                try {
                    throw(message="not empty", detail="not empty either")
                } catch (any e) {
                    expect(e.message).notToBeNull()
                    expect(e.detail).notToBeNull()
                    expect(e.detail).notToBeEmpty()
                }
            })

            it("wri", () => {
                try {
                    throw(type="MyException", message="my message", detail="my detail", extendedInfo="my extended info");
                } catch (any e) {
                    writeDump([
                        type = e.type,
                        message = e.message,
                        detail = e.detail,
                        extendedInfo = e.extendedInfo
                    ])
                }
            })
        })
    }
}
