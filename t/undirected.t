#!/usr/bin/perl -w

# Test additional options in as_graph():

use Test::More;
use strict;

BEGIN
   {
   plan tests => 22;
   chdir 't' if -d 't';
   use lib '../lib';
   use_ok ("Graph::Convert") or die($@);
   };

can_ok ("Graph::Convert", qw/
  as_graph
  as_multiedged_graph
  as_graph_easy
  /);

#############################################################################
# test undirected graphs

my $ge = Graph::Easy->new();

is (ref($ge), 'Graph::Easy');
$ge->add_edge( 'Bonn', 'Berlin', 'by train' );

is (scalar $ge->nodes(), 2, '2 nodes');
is (scalar $ge->edges(), 1, '1 edges');
is ($ge->is_simple_graph(), 1, 'simple graph (2 nodes, 1 edge)');

my $graph = Graph::Convert->as_graph( $ge, { undirected => 1 } );

is (scalar $graph->vertices(), 2, '2 nodes');
is (scalar $graph->edges(), 1, '1 edges');
ok ($graph->is_undirected(), 'is undirected');

is ($graph->is_simple_graph(), 1, 'simple graph (2 nodes, 1 edge)');

my $graph_easy = Graph::Convert->as_graph_easy( $graph );

is (scalar $graph_easy->nodes(), 2, '2 nodes');
is (scalar $graph_easy->edges(), 1, '1 edges');
is ($graph_easy->is_simple_graph(), 1, 'simple graph (2 nodes, 1 edge)');


#############################################################################
# repeat the former test, but reverse the node order to test for the bug
# in Graph 0.81:

$ge = Graph::Easy->new();

is (ref($ge), 'Graph::Easy');
$ge->add_node( 'Berlin' );
$ge->add_node( 'Bonn' );
$ge->add_edge( 'Bonn', 'Berlin', 'by train' );

is (scalar $ge->nodes(), 2, '2 nodes');
is (scalar $ge->edges(), 1, '1 edges');
is ($ge->is_simple_graph(), 1, 'simple graph (2 nodes, 1 edge)');

$graph = Graph::Convert->as_graph( $ge, { undirected => 1 } );

is (scalar $graph->vertices(), 2, '2 nodes');
is (scalar $graph->edges(), 1, '1 edges');
ok ($graph->is_undirected(), 'is undirected');

is ($graph->is_simple_graph(), 1, 'simple graph (2 nodes, 1 edge)');

$graph_easy = Graph::Convert->as_graph_easy( $graph );

is (scalar $graph_easy->nodes(), 2, '2 nodes');

