
# We need at least Perl 5.8.1 (for Graph::Easy & Unicode support)
require 5.8.1;
use strict;

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# The name of your distribution
name		'Graph-Convert';

# Get most of the details from the primary module
all_from	'lib/Graph/Convert.pm';

requires	'Graph'		=> 0.80;
requires	'Graph::Easy'	=> 0.48;

recommends	'Graph::Easy::Manual'	=> 0.34;

build_requires	'Test::More'	=> 0.42;

license		'gpl';		# v2.0 only 

author		'Tels <nospam-abuse@bloodgate.com>';

# Generate the Makefile
WriteAll;
