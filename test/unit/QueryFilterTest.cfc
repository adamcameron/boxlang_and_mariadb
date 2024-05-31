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

            it("works on a zero-row query", () => {
                var empty = queryNew("id")
                var stillEmpty = empty.filter((row) => true)

                expect(stillEmpty.recordCount).toBe(empty.recordCount)
            })

            it("works with a zero-row directoryList result", () => {
                var files = directoryList(
                    path = getDirectoryFromPath(getCurrentTemplatePath()),
                    filter = "*.none",
                    listInfo = "query",
                    type = "file"
                )
                var onlyTests = files.filter((row) => row.name contains "Test.cfc")

                expect(onlyTests.recordCount).toBe(files.recordCount)
            })

            it("works with a zero-row cfdirectory result", () => {
                cfdirectory(
                    directory = getDirectoryFromPath(getCurrentTemplatePath())
                    action = "list"
                    filter = "*.none"
                    name = "onlyNones"
                )
                var onlyTests = onlyNones.filter((row) => row.name contains "Test.cfc")

                expect(onlyTests.recordCount).toBe(onlyNones.recordCount)
            })
        })
    }
}
