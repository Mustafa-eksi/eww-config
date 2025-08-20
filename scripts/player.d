import std.stdio : writeln;
import std.process : execute;
import std.string : strip, empty, split, join;
import std.algorithm.mutation : remove;

void main() {
    auto result = execute(["playerctl", "status"]);
    if (result.status != 0) return; 
    auto player_status = result.output.strip();
    if (player_status == "No players found") return;

    result = execute(["playerctl", "metadata"]);
    if (result.status != 0) return; 
    auto lines = result.output.strip().split('\n');
    string[string] keyval;
    string provider;
    foreach (line; lines) {
        if (line.empty()) continue;
        auto columns = line.split(' ');
        columns = columns.remove!(a => a.empty());
        keyval[columns[1]] = columns[2..$].join(' ');
        provider = columns[0];
    }
    if (keyval["mpris:artUrl"].length < 8) return;
    writeln(`
    (box :orientation "h" :space-evenly false :spacing 5
        (image :class "music-art" :image-width 25 :image-height 25 :path "`~keyval["mpris:artUrl"][7..$]~`")
        (label :class "music-title" :text "`~keyval["xesam:title"]~`")
    )
    `);
}
