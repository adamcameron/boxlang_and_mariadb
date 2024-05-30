import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("Tests the DB", () => {
            it("can connect to the DB", () => {
                var result = queryExecute("SELECT @@VERSION as version")

                expect(result).toHaveLength(1)
                expect(listFindNoCase(result.columnList, "version")).toBeTrue()
                expect(result.version[1]).toContain("mariadb")
            })
            it("can make a second connection to the DB", () => {
                var result = queryExecute("SELECT @@VERSION as version")

                expect(result).toHaveLength(1)
                expect(listFindNoCase(result.columnList, "version")).toBeTrue()
                expect(result.version[1]).toContain("mariadb")
            })
		})
    }
}
