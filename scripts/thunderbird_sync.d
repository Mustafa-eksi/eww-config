#!/usr/bin/rdmd

import etc.c.sqlite3 : sqlite3, sqlite3_open, sqlite3_exec, sqlite3_close;
import std.stdio : writeln;
import std.string : fromStringz;
import std.conv : to;
import std.datetime : SysTime, usecs;

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
    sqlite3* db;
    scope(exit) {
        if (db) sqlite3_close(db);
    }
    Event[] events;
    if (sqlite3_open("/home/mustafa/.thunderbird/ntuc11tl.default-release/calendar-data/local.sqlite", &db)) return -1;
    if (sqlite3_exec(db, GET_EVENTS, &db_select_callback, cast(void*)&events, cast(char**)null)) return -1;
    foreach(event; events) {
        writeln(event.title, " - ", event.start);
    }
    return 0;
}
