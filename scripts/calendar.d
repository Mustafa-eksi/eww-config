#!/usr/bin/rdmd


import etc.c.sqlite3 : sqlite3, sqlite3_open, sqlite3_exec, sqlite3_close;
import std.stdio : writeln, writef;
import std.string : fromStringz, strip, empty;
import std.conv : to;
import std.datetime : SysTime, usecs, Clock;
import std.array : split;
import std.process : execute;
import std.algorithm.searching : canFind;

struct Event {
    char[256] title;
    SysTime start;
};

extern(C)int db_select_callback(void* data, int argc, char** argv, char** azColName) {
    // Worst code of my life but it works
    Event[]* events = cast(Event[]*)data;
    char[256] title;
    char[] titlez = fromStringz(*argv);
    title[0..titlez.length] = titlez;
    argv++;
    char[] start_str = fromStringz(*argv);
    SysTime start = SysTime(to!long(start_str, 10)*10);
    start.year = start.year + 1969;
    (*events)[events.length++] = Event(title, start);
    return 0;
}

const(char)* GET_EVENTS = `select title,event_start from main.cal_events`;
int main() {

    // get events
    sqlite3* db;
    scope(exit) {
        if (db) sqlite3_close(db);
    }
    Event[] events;
    if (sqlite3_open("/home/mustafa/.thunderbird/ntuc11tl.default-release/calendar-data/local.sqlite", &db)) return -1;
    if (sqlite3_exec(db, GET_EVENTS, &db_select_callback, cast(void*)&events, cast(char**)null)) return -1;

    auto today = to!string(Clock.currTime().day, 10);
    auto res = execute(["cal", "-m"]);
    if (res.status != 0) return -1;

    auto lines = res.output.split('\n');
    auto month_year = lines[0].strip().split(' ');
    auto days = lines[1].strip().split(' ');
    writeln(`(box :orientation "vertical"`);
    writeln(`(box :orientation "horizontal" :class "cal-top-bar"`);
    writeln(`   (label :class "calendar-text" :halign "center" :text "`~month_year[0]~` `~month_year[1]~`")`);
    //writeln(`   (button :class "calender-close" :halign "end" :onclick "eww close takvim" "X")`);
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
            auto class_str = "calendar-cell-base";
            if (!day.empty()) {
                auto thisdate = Clock.currTime();
                thisdate.day = to!int(day);
                if (day.strip() == today)
                    class_str ~= " calendar-cell-today";
                foreach(event; events) {
                    if (event.start.toISOExtString()[0..10] == thisdate.toISOExtString()[0..10]) {
                        class_str ~= " calendar-cell-event";
                        break;
                    }
                }
            }
            writeln(`       (label :class "`~class_str~`" :text "`~day~`")`);
        }
        writeln(`   )`);
    }
    writeln(`)`);
    return 0;
}
