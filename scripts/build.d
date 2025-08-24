#!/usr/bin/rdmd

import std.process : execute;
import std.stdio : writeln;
import std.string : empty;

bool compile(string filename, string[] extra_arg=[]) {
    auto result = execute(["dmd", filename]~extra_arg);
    if (!result.output.empty())
        writeln(result.output);
    return result.status == 0;
}

int main() {
    if (!compile("calendar.d", ["-L-lsqlite3"])) return -1;
    if (!compile("workspaces.d")) return -1;
    if (!compile("player.d")) return -1;
    if (!compile("playerctlstatus.d")) return -1;
    if (!compile("launcher.d")) return -1;
    writeln("Compilation successful");
    return 0;
}
