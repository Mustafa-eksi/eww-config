#!/usr/bin/rdmd

import std.process : execute;
import std.stdio : writeln;
import std.array : split;
import std.string;

void main() {
    auto res = execute(["hyprctl", "activeworkspace"]);
    if (res.status != 0) return;
    auto active = res.output.strip().split("workspace ID ")[1][0];

    res = execute(["hyprctl", "workspaces"]);
    if (res.status != 0) return;
    auto ar = res.output.strip().split("workspace ID ");
    writeln("(box :spacing 5");
    foreach(a; ar) {
        if (a.empty()) continue;
        if (active == a[0]) {
            writeln(`(button :class "active-workspace" :halign "start" :onclick "hyprctl dispatch workspace `~a[0]~`" "`~a[0]~`")`);
        } else {
            writeln(`(button :class "inactive-workspace" :halign "start" :onclick "hyprctl dispatch workspace `~a[0]~`" "`~a[0]~`")`);
        }
    }
    writeln(")");
}
