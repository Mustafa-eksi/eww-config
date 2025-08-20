import std.stdio : writeln;
import std.process : execute;

int main() {
    writeln(execute(["playerctl", "status"]).output);
    return 0;
}
