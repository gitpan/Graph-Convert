#!/usr/bin/perl -w

# Some basic tests:

use Test::More;
use strict;

BEGIN
   {
   plan tests => 12;
   chdir 't' if -d 't';
   use lib '../lib';
   use_ok ("Graph::Convert") or die($@);
   };

can_ok ("Graph::Convert", qw/
  as_graph
  as_graph_easy
  /);

#############################################################################
# both Graph and Graph::Easy are automatically loaded:

my $ge = Graph::Easy->new();

is (ref($ge), 'Graph::Easy');
$ge->add_edge( 'Bonn', 'Berlin', 'by train' );

is (scalar $ge->nodes(), 2, '2 nodes');
is (scalar $ge->edges(), 1, '1 edges');
is ($ge->is_simple_graph(), 1, 'simple graph (2 nodes, 1 edge)');

my $graph = Graph::Convert->as_graph( $ge );

is (scalar $graph->vertices(), 2, '2 nodes');
is (scalar $graph->edges(), 1, '1 edges');
is ($graph->is_simple_graph(), 1, 'simple graph (2 nodes, 1 edge)');

my $graph_easy = Graph::Convert->as_graph_easy( $graph );

is (scalar $graph_easy->nodes(), 2, '2 nodes');
is (scalar $graph_easy->edges(), 1, '1 edges');
is ($graph_easy->is_simple_graph(), 1, 'simple graph (2 nodes, 1 edge)');


