<?php

$ping = ["name" => "ping",
         "attrs" => ["xmlns" => "urn:xmpp:ping:1"]];

$resp = "<presence/>";
switch ($_REQUEST["name"]) {
    case "iq":
        $resp = snatch_iq_error($_REQUEST, "feature-not-implemented");
        break;
    case "message":
        $from = $_REQUEST["attrs"]["from"];
        $to = $_REQUEST["attrs"]["to"];
        $id = $_REQUEST["attrs"]["id"];
        $payload = $_REQUEST["children"];
        $resp = snatch_message_error($to, $from, $id, $payload, "service-unavailable");
        snatch_send_binary(snatch_iq($to, $from, "1234", "get", [$ping]));
        break;
}
snatch_send_binary($resp);
