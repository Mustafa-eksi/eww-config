#!/usr/bin/rdmd

import std.stdio : writeln, writef;
import std.process : execute;
import std.array : split;
import std.string : strip, empty;
import std.datetime.systime : Clock;
import std.conv : to;

void main() {
    auto today = to!string(Clock.currTime().day, 10);
    auto res = execute(["cal", "-m"]);
    if (res.status != 0) return;

    auto lines = res.output.split('\n');
    auto month_year = lines[0].strip().split(' ');
    auto days = lines[1].strip().split(' ');
    writeln(`(box :orientation "vertical"`);
    writeln(`(box :orientation "horizontal"`);
    writeln(`   (label :class "calendar-text" :halign "end" :text "`~month_year[0]~` `~month_year[1]~`")`);
    writeln(`   (button :class "calender-close" :halign "end" :onclick "eww close takvim" "X")`);
    writeln(`)`);
    writeln(`   (box :orientation "horizontal" :spacing 5`);
    foreach(day; days) {
        writeln(`       (label :class "calendar-cell-days" :text "`~day~`")`);
    }
    writeln("   )");
    foreach(line; lines[2..$]) {
        if (line.strip().empty()) continue;
        writeln(`   (box :orientation "horizontal" :spacing 5`);
        for (size_t i = 0; i < line.length; i += 3) {
            auto day = line[i..i+2].strip();
            if (day.strip() == today)
                writeln(`       (label :class "calendar-cell-today" :text "`~day~`")`);
            else
                writeln(`       (label :class "calendar-cell" :text "`~day~`")`);
        }
        writeln(`   )`);
    }
    writeln(`)`);
}
