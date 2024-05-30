import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("Repro cases for DB-oriented bugs", () => {
            it("mishandles dates from the DB", () => {
                var result = queryExecute("SELECT curdate() as my_date")

                expect(result).toHaveLength(1)
                expect(listFindNoCase(result.columnList, "my_date")).toBeTrue()
                expect(result.my_date[1]).notToBeNull()
                expect(result.my_date[1].getClass().getName()).toBe("java.sql.Date")
                expect(() => {
                    isNumeric(result.my_date[1])
                }).notToThrow()
            })
		})
    }
}
