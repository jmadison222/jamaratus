# Installation

On a robust system, you might have all the system dependencies in place, so let's just jump 
right in.  Do this:

* Put everything from the `scripts` directory into any directory in your PATH.
* Run `. jamaratus` at your command line.  There is a space after that dot!
* Run `line1 Hello` to get the following output, where the line should fit your screen precisely:

```
----------------------------------------------------------------------------------------
-- Hello
--
```

* Run any of the following commands:

```
action # Print a message in the format that tells the user to take an action.
announce # Print the file header of the script that calls this function.
aspect # Manage the aspects that are common to functions.
cache # Manage cache files across other components.
clr # Manage screen colors.  (printf)
confirm # Return 0 or 1 based on user confirmation.
dir # Directory listing in various forms.
evalx # The 'eval' wrapper, mostly to echo the command first.  (eval)
g # The 'git' wrapper.
krb # Manage Kerberos.  (kinit, klist, kdestroy)
line1 # The first-level visual break.  (tput cols, perl, clr)
line2 # The second-level message within line1.  (clr)
popdx # The 'popd' wrapper, mostly to hide the echo to stdout.
prompt # Run some other function in prompt mode.
pushdx # The 'pushd' wrapper, mostly to hide the echo to stdout.
s3 # Manage S3 on AWS.
snow # Manage Snowflake, the cloud-based relational database.
usage # Print P1 in the 'usage' message format.
```

# System Dependencies
If the commands don't just work, there may be missing system dependencies or
settings.  Try these:

**Use bash** - These have only been tested thoroughly on bash.

**Use TERM=xterm** - Set the TERM varaible to `xterm`.  It may work with other settings too.


# Use Within Scripts

Once things are working on the command line, use the scripts within your scripts by doing this:

* Put the following string at the top of any shell script:

    . jamaratus

Then use the commands within the script just as you would at the command line.


# About the Name

To __jam__ is to play musical instruments with great intensity.  An __apparatus__ is 
the technical equipment and instruments needed for a particular activity or 
purpose.  __Jamaratus__ is a collection of Linux shell utilities that make your 
command line rock!

