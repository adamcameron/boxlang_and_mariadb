<!DOCTYPE html>
<html lang="en">
<head><!--hrm--->
</head>
<body>
    <main>
        <h1>Welcome to My Website</h1>
    </main>
</body>
</html>

<cfsavecontent variable="headStuff">
    <meta charset="UTF-8">
    <title>My Website</title>
</cfsavecontent>
<cfhtmlhead text="#headStuff#">
