import testbox.system.BaseSpec

component extends=BaseSpec {

    function run() {
        describe("tests query filtering", () => {
            it("supports .filter", () => {
                var week = queryNew("id,en,mi", "integer,varchar,varchar", [
                    [1,"Monday","Rāhina"],
                    [2,"Tuesday","Rātū"],
                    [3,"Wednesday","Rāapa"],
                    [4,"Thursday","Rāpare"],
                    [5,"Friday","Rāmere"],
                    [6,"Saturday","Rāhoroi"],
                    [7,"Sunday","Rātapu"]
                ])

                var weekend = week.filter((row) => row.id >= 6)

               expect(valueList(weekend.id)).toBe("6,7")
            })

            it("supports .filter on a directoryList result", () => {
                var files = directoryList(
                    path = getDirectoryFromPath(getCurrentTemplatePath()),
                    listInfo = "query",
                    type = "file"
                )
                var onlyTests = files.filter((row) => row.name contains "Test.cfc")

                expect(onlyTests.recordCount).toBe(files.recordCount)
            })
        })
    }
}
