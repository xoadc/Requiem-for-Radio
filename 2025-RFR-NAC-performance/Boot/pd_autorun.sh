# wait for computer to finish boot
sleep 5

# Kill all potential audio servers
killall jackd qjackqtl
sleep 3

# Start Jack Audio server
jackd -dalsa -dhw:2 -r44100 -p1024 -n2 &
sleep 10

# Start SuperCollider
scide /home/adc/Desktop/Requiem-for-Radio/RFR-FQF-PulDe-theremin/sc-code/main.scd &
SCIDE_PID=$!

# Wait for the IDE to load
sleep 5

# Find line command
wtype -M ctrl -k "L" -m ctrl
sleep 0.1

# Jump to 32
wtype "32"
sleep 0.1
wtype -k Return
sleep 0.1

# Run code @ Line 32
wtype -M ctrl -k Return -m ctrl
sleep 10

sleep 3

export DISPLAY=:0
xrandr --output HDMI-1 --mode 1920x1080 --pos 0x0 --output HDMI-2 --mode 1920x1080 --pos 0x0

/home/adc/Desktop/Processing/Processing/bin/Processing cli --sketch=/home/adc/Desktop/Requiem-for-Radio/RFR-FQF-PulDe-theremin/bluePrints --run
PROC_PID=$!

wait $SCIDE_PID $PROC_PID
