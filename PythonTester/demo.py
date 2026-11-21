
import subprocess
import threading
import json
import sys
import os
import signal

# for proper Python file system events,
# consider something grown up like “watchdog” 
# woof woof 🐕🐶
#
# https://pypi.org/project/watchdog/
#
# having said that…
#
# this shows how to run command line app in subprocess
# and how to check the app’s stdout in a thread,
# every line from the app parsed to a JSON object
# and passed as an “event” to function
# which in this case just prints it out

# --------------------------------------------------
# "constants"
# --------------------------------------------------

# to working dir…

# WATCHER = "./FSEvents"

# or not to working dir…

SCRIPT_DIR = os.path.dirname( os.path.abspath( __file__ ) )
WATCHER = os.path.join( SCRIPT_DIR, "FSEvents" )

# that is the question

# yes, we are going to spy on your desktop folder…

WATCH_PATHS = [ os.path.expanduser( "~/Desktop" ) ]

# --------------------------------------------------
# shared - ie: the globals ! (well, the above too)
# --------------------------------------------------

gProcess = None
gReaderThread = None
gStopEvent = threading.Event()

# --------------------------------------------------
# event handler - JSON object passed in event
# --------------------------------------------------

def handle_event( event ):

    path = event.get( "path", "" )
    event_id = event.get( "id", "" )
    flags = event.get( "flags", {} )

    active_flags = [

        name for name, value in flags.items()
        if value
    ]

    print()
    print( "EVENT" )
    print( "  Path:  ", path )
    print( "  ID:    ", event_id )
    print( "  Flags: ", ", ".join( active_flags ) )
    print( "-" * 60 )

# --------------------------------------------------
# reader - runs in thread, line becomes JSON object
# --------------------------------------------------

def reader():

    print( "Reader thread started" )

    try:

        for line in gProcess.stdout:

            if gStopEvent.is_set(): break

            line = line.strip()

            if not line: continue

            try:

                event = json.loads( line )
                handle_event( event )

            except json.JSONDecodeError as error:

                print( "JSON error:", error )

    except Exception as error:

        print( "Reader error:", error )

    print( "Reader thread stopped" )

# --------------------------------------------------
# start watcher
# --------------------------------------------------

def start_watcher():

    global gProcess, gReaderThread

    if not os.path.isfile( WATCHER ):

        print( "FSEvents executable not found:", WATCHER )
        return False

    command = [ WATCHER ] + WATCH_PATHS

    print( "Starting FSEvents" )
    print( "Watching:" )

    for path in WATCH_PATHS: print( " ", path )

    try:

        gProcess = subprocess.Popen(

            command,
            stdout = subprocess.PIPE,
            stderr = None,
            text = True,
            bufsize = 1
        )

    except Exception as error:

        print( "Unable to launch FSEvents:", error )
        return False

    gReaderThread = threading.Thread(

        target = reader,
        name = "FSEventsReader",
        daemon = True
    )

    gReaderThread.start()

    return True

# --------------------------------------------------
# shutdown - stop
# --------------------------------------------------

def stop_watcher():

    print( "\nStopping FSEvents..." )

    gStopEvent.set()

    if gProcess and gProcess.poll() is None:

        gProcess.terminate()

        try:

            gProcess.wait( timeout = 3 )

        except subprocess.TimeoutExpired:

            print( "FSEvents did not terminate; killing it" )

            gProcess.kill()
            gProcess.wait()

    if gReaderThread: gReaderThread.join( timeout = 2 )

    print( "Shutdown complete" )

# --------------------------------------------------
# main - entry point
# --------------------------------------------------

def main():

    if not start_watcher(): return 1

    try:

        print( "\nPress Ctrl-C to stop watching.\n" )

        while gProcess.poll() is None: gStopEvent.wait( 0.2 )

    except KeyboardInterrupt:

        pass

    finally:

        stop_watcher()

    return 0

if __name__ == "__main__": sys.exit( main() )

