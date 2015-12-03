#! /usr/bin/env perl
#####################################################################
#  Script      : birthdays.pl
#  Version     : 2.01
#  Author      : Tony Annese
#  Date        : 12/01/2015
#  Last Edited : 12/03/2015
#  Description : Read in a csv file with birth dates and
#                it will tell you how many days until the
#                next birthday
#####################################################################
# Purpose:
# - To be able to use as a standalone or as a Mac OSX Geektool 
#   applet to act as a countdown timer to a list of birthdays
#   as supplied by a csv formatted file
# Requirements:
# - .csv file in format of:
#   #Event,Date in mm/dd/yyyy format
#   Event Description,mm/dd/yyyy
# - .csv file must be indicated as a command line parameter
# Method:
# - N/A
# Syntax: birthdays inputfile
# Future Upgrades:
# - Use getopts() to load command line options for the csv file
# - Read in all the dates and birthdays and then sort them based on
#   closest birthday
# - Colorize output so that birthdays that are occurring in less
#   than a month are in yellow and less than 2 weeks are in red
#   Or maybe change the background color
#
# Change Log:
# 1.0   12/01/2015  Initial Version
# 2.0   12/02/2015  Changed whole math section to:
#                   -Read in the date and create a new date object
#                    with the read in date
#                   -Use delta_days to figure out how many days
# 2.01  12/03/2015  Moved the comparison for birthdays that have
#                   already passed out of the section where I 
#                   output the information
#
#####################################################################



use strict;
use warnings;
use diagnostics;

use TEXT::CSV;
use DateTime::Duration;
use DateTime::Format::Strptime;
use DateTime::Format::Duration;

# Set the csv file seperator character. Change if you use something other
# than a comma
my $csv = Text::CSV->new({ sep_char => ',' });

# We need to get todays date
my $today = DateTime->today();


# Was an input csv file indicated on the command line?
my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";

# Open the file and read in the header file which we dont use
# but it is there to show people how to format the dates
open(my $data, '<', $file) or die "Coule not open '$file' $!\n";
my $header= $csv->getline ($data);

# Start parsing the data
while (my $line = <$data>) {
    chomp $line;

    if ($csv->parse($line)) {

        my @fields = $csv->fields();
        my $parser = DateTime::Format::Strptime->new(pattern =>'%m/%d/%Y');
# Create the birthday object
        my $birthday = $parser->parse_datetime($fields[1]);
# Create a duplicate birthday object to do the date math to
        my $tbirthday = $parser->parse_datetime($fields[1]);

#        print "Birthday month is: ", $tbirthday->month,"\n\n";
# Set the temp objects year to this year        
        if ($tbirthday->month < $today->month) {
            $tbirthday->set_year($today->year+1);
        } elsif (($tbirthday->month == $today->month) && ($tbirthday->day <$today->day)) {
            $tbirthday->set_year($today->year+1);
        } else {
            $tbirthday->set_year($today->year);
        }
#
# Determine how many days between today and $tbrirthday
    my $dur = $today->delta_days($tbirthday)->delta_days;

#Print out the information
    if ($dur == 0) {
        print $fields[0], " is today!\n";
    } elsif ($dur > 0) {
        print $fields[0], " is in $dur days!\n";
    }

    } else {
        warn "Line could not be parsed: $line\n";
    }
}
