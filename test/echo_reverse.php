<?php

$attrs = $_REQUEST["attrs"];
$text = strrev($_REQUEST["children"][0]["children"][0]);

$response = [
    "name" => "message",
    "attrs" => [
        "from" => $attrs["to"],
        "to" => $attrs["from"],
        "id" => $attrs["id"],
        "type" => $attrs["type"]
    ],
    "children" => [
        [
            "name" => "body",
            "children" => [$text]
        ]
    ]
];

var_dump($response);

snatch_send($response, $attrs["from"]);
