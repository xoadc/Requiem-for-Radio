# wait for computer to finish boot
sleep 10
#log in to network
sudo ifconfig wlan0 down

# Kill all potential audio servers
killall jackd qjackqtl
sleep 15

# Start Jack Audio server
jackd -dalsa -dhw:2 -r44100 -p1024 -n2 &
sleep 15

# Start SuperCollider
scide /home/adc/Desktop/Requiem-for-Radio/RFR-FQF-NDZ-13towers/NDZ/main.scd &
SCIDE_PID=$!

# Wait for the IDE to load
sleep 10

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
sleep 15

# Find line command
wtype -M ctrl -k "L" -m ctrl
sleep 0.1

# Jump to 52
wtype "52"
sleep 0.1
wtype -k Return
sleep 0.1

# Run code @ Line 52
wtype -M ctrl -k Return -m ctrl
sleep 3

wait $SCIDE_PID
