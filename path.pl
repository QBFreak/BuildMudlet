#!/bin/perl
use warnings;
use strict;

my $sAddPathName = "MUDLET_PATH";
my $sAddPath = "";
#if (scalar(@ARGV) == 1) {
#   $sAddPath = $ARGV[0];
#} elsif (scalar(@ARGV) > 1) {
#    warn("More than one set of PATHs on the command line. Perhaps you meant to enclose them in double quotes?");
#    $sAddPath = join(";",@ARGV);
#} elsif (scalar(@ARGV) == 0) {
#    print "Usage: path.pl \"path\\to\\add;other\\path\\to\\add\"\n";
#    print "  Adds a path or paths to the PATH environemnt variable for the current user.\n";
#    print "   Because the command to do this limits environment variables to 1,024\n";
#    print "   characters, the current user's PATH is stripped of any duplicates from the\n";
#    print "   System PATH. In addition, the elements added by this script are stored in a\n";
#    print "   seperate variable which is added to the current user's PATH, thus shortening\n";
#    print "   it further. When %PATH% is referenced, the System PATH is concatenated with\n";
#    print "   the current users' PATH, and the added path from this script is expanded.\n";
#    exit 0;
#}

### This script COULD be generic, if we uncommented the above and deleted this
###  line here. But we're super lazy. And this WAS written to assist building
###  Mudlet for Windows after all.
$sAddPath = 'C:\Python27;C:\mingw32\bin;C:\mingw32\msys\bin;C:\Program Files (x86)\CMake\bin;C:\Qt\5.6\mingw49_32\bin';

# Clean up the new Paths
#  * double the backslashes
#$sAddPath =~ s/([^\\])\\([^\\])/$1\\\\$2/g;
#$sAddPath =~ s/^(.*)\\$/$1\\\\/;

# Get the current value of %PATH% for the current user and clean it up:
#  * get rid of new lines
#  * double the backslashes
#  * split it into an array of paths on ';'
my $sPath = qx(cmd.exe /c "echo %PATH%");
$sPath =~ s/[\r\n]//g;
#$sPath =~ s/([^\\])\\([^\\])/$1\\\\$2/g;
#$sPath =~ s/^(.*)\\$/$1\\\\/;
my @aPath = split /;/, $sPath;

# Get the current value of the _system_ env variable PATH and clean it up:
#  * get rid of the prefix from the reg query command
#  * run it through an 'ECHO' to expand any environment variables
#  * get rid of new lines
#  * double the backslashes
#  * split it into an array of paths on ';'
my $sAllUsersPath = qx(cmd.exe /c 'reg query \"HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\" /v PATH');
$sAllUsersPath =~ s/.*\n\s+PATH\s+REG_EXPAND_SZ\s+([^\s].*)[\r\n]+/$1/;
$sAllUsersPath =~ s/[\r\n]//g; # Don't remove this
$sAllUsersPath = qx(cmd.exe /c 'echo $sAllUsersPath');
$sAllUsersPath =~ s/[\r\n]//g; # Or this! We need both
#$sAllUsersPath =~ s/([^\\])\\([^\\])/$1\\\\$2/g;
#$sAllUsersPath =~ s/^(.*)\\$/$1\\\\/;
my @aAllUsersPath = split /;/, $sAllUsersPath;

# Remove all system paths from the user path
my $j = 0;
for (my $i = 0; $i < scalar(@aAllUsersPath); $i++) {
    $j = 0;
    while ($j <= $#aPath ) {
        if ( lc $aAllUsersPath[$i] eq lc $aPath[$j] ) {
            splice @aPath, $j, 1;
        } else {
            $j++;
        }
    }
}

# Remove any duplicates from the user path
my %hPath = map { $_ => 1} @aPath;
@aPath = keys %hPath;

# Put our new current user path back together
$sPath = join(';', @aPath);

# Get the current value of %$sAddPathName%
my $sCurAddPath = qx(cmd.exe /c "echo %$sAddPathName%");

# Set the custom path
#(my $sDisplayAddPath = $sAddPath) =~ s/\\\\/\\/g;
print("\n$sAddPathName=$sAddPath\n");
system("cmd.exe /c 'SETX $sAddPathName \"$sAddPath'");

# Check and see if %$sAddPathName% was set
#  If it is, assume that %$sAddPathName% is already in %PATH%
if ($sCurAddPath =~ /%$sAddPathName%\r\n/) {
    #Nope! Add it to %PATH%
    if (length($sPath) > 0) {
        # Put our stuff at the BEGINNING, this solves some Mudlet specific
        # issues with Lua for Windows being installed. Presuming it's not in
        # the System PATH anyway, *sigh*.
        $sPath = join(';', "%$sAddPathName%", $sPath);
    } else {
        $sPath = "%$sAddPathName%";
    }
    #(my $sDisplayPath = $sPath) =~ s/\\\\/\\/g;
    print("\nPATH=$sPath\n");
    system("cmd.exe /c 'SETX PATH \"$sPath'");
}
