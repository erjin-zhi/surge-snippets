var body = $response.body;
var obj = JSON.parse(body);
obj.data.ifvip="Y";
body = JSON.stringify(obj);
$done({
    body
});