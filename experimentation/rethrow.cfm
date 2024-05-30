<cfscript>
    try {
        throw(
            type = "me.adamcameron.SomeException",
            message = "special exception",
            detail = "oooh so special"
        )

    } catch ("me.adamcameron.SomeException" e) {
        writeOutput("caught it")
        rethrow;
    } catch (any e) {
        writeDump([
            type = e.type,
            message = e.message,
            detail = e.detail
        ])
    }
</cfscript>
