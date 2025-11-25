import std.stdio : writeln;
import std.process : execute;
import std.file : dirEntries, SpanMode, read;
import std.string: split, startsWith, strip, toLower, endsWith, join;
import std.algorithm.mutation : remove;
import std.algorithm.searching : find, canFind;

struct DesktopEntry {
    char[] name;
    char[] exec;
    char[] icon;
    string filepath;

    this(string _filepath) {
        filepath = _filepath;
        char[] filecontent = cast(char[])read(filepath);
        auto lines = filecontent.split('\n');

        auto names = lines.remove!((line) => !line.startsWith("Name="));
        if (names.length == 0) return;
        name = names[0].split("=")[1];

        auto execs = lines.remove!(line => !line.startsWith("Exec="));
        if (execs.length == 0) return;
        exec = execs[0].split("=")[1];
        exec = exec.split(" ").remove!(a => a.startsWith("%")).join(" ");

        auto icons = lines.remove!(line => !line.startsWith("Icon="));
        if (icons.length == 0) return;
        icon = icons[0].split("=")[1];
    }
};

const DESKTOP_ENTRY_DIRECTORY = "/usr/share/applications";
const ICON_DIRECTORY_SEARCH = "/usr/share/icons/hicolor/*/apps/*.png";
void main(string[] args) {
    bool launch = args.canFind("--launch"); // launch the first result

    // Index entries
    DesktopEntry[] entries;
    foreach(string desktop_entry; dirEntries(DESKTOP_ENTRY_DIRECTORY, SpanMode.shallow)) {
        if (desktop_entry.endsWith(".desktop"))
            entries[entries.length++] = DesktopEntry(desktop_entry);
    }
    // Search
    if (args.length != 1 && !launch) {
        entries = entries.remove!(e => !e.name.toLower().startsWith(args[1].strip().toLower()));
    } else if (launch) {
        auto searchResult = entries.remove!(e => !e.name.toLower().startsWith(args[1].strip().toLower()));
        if (searchResult.length != 0) {
            auto hyprResult = execute(["hyprctl", "dispatch", "exec", searchResult[0].exec]);
            writeln(["hyprctl", "dispatch", "exec", searchResult[0].exec]);
            if (hyprResult.status != 0) {
                writeln(hyprResult.output);
            }
            return;
        }
    }

    auto find_result = execute(["bash", "-c", "find "~ICON_DIRECTORY_SEARCH]);
    if (find_result.status != 0) {
        writeln("Find error");
    }
    auto iconfiles = find_result.output.strip().split('\n');

    string finalwidget;
    // Generate yuck
    finalwidget ~= `(box :active true :class "launcher-list" :orientation "v" :space-evenly false :spacing 5 `;
    foreach(i, entry; entries) {
        finalwidget ~= `(box :class "launcher-element" :height 24 :orientation "h" :space-evenly false :spacing 10`;
        //if (i == 0) finalwidget ~= ` :class "launcher-first"`;
        auto iconpath = iconfiles.find!(e => e.endsWith(entry.icon~".png"));
        if (iconpath.length != 0)
            finalwidget ~= `   (image :image-width 24 :image-height 24 :path "`~iconpath[0]~`")`;
        finalwidget ~= `   (input :class "launcher-el-input" :onaccept 'hyprctl dispatch exec "`~entry.exec~`" && eww close launcher' :value "`~entry.name~`")`;
        //finalwidget ~= `   (checkbox :active true :class "launcher-check" :onchecked 'hyprctl dispatch exec "`~entry.exec~`" && eww close launcher')`;
        finalwidget ~= `)`;
    }
    finalwidget ~= `)`;
    //writeln(finalwidget);
    auto result = execute(["eww", "update", `launcher_body=`~finalwidget~``]);
    if (result.status != 0) {
        writeln(result);
    }
}
