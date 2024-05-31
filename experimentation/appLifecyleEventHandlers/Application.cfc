component {
    this.name = "app1_#createUuid()#"

    public void function onRequest(required string targetPage) {
        writeOutput("onRequest targetPage: #targetPage#<br>")
        include targetPage
    }

    public void function onRequestEnd(string targetPage) {
        writeOutput("targetPage: #targetPage#<br>")
    }
}
