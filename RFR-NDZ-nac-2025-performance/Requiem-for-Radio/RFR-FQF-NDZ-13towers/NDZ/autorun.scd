(
   3.wait;
   "main.scd".loadRelative;

    var code = File.readAllString("./main.scd");
    var lines = code.split($\n);

    interpret(lines[31]);
    5.wait;

    interpret(49);
)