<?php

$attrs = &$_REQUEST["attrs"];
$text = strrev($_REQUEST["children"][0]["children"][0]);
$payload = [["name" => "body", "children" => [$text]]];
snatch_send_binary(snatch_message($attrs["to"], $attrs["from"],
                                  $attrs["id"], $attrs["type"],
                                  $payload));
