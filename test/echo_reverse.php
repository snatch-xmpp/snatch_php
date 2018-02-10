<?php

$attrs = $packet["attrs"];
$text = strrev($packet["children"][0]["children"][0]);

$response = [
    "name" => "message",
    "attrs" => [
        "from" => $attrs["from"],
        "to" => $attrs["to"],
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

snatch_send($response, $attrs["to"]);
