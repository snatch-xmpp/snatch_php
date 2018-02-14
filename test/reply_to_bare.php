<?php

$attrs = $_REQUEST["attrs"];
$bare_jid = snatch_bare_jid($attrs["from"]);

$response = [
    "name" => "message",
    "attrs" => [
        "from" => $attrs["to"],
        "to" => $bare_jid,
        "id" => $attrs["id"],
        "type" => "chat"
    ],
    "children" => [
        [
            "name" => "body",
            "children" => ["Hey there!"]
        ]
    ]
];

print "received response from ${attrs['to']} send back to $bare_jid";

snatch_send($response, $bare_jid);
