#!/usr/bin/perl -w

# Convert attributes

use Test::More;
use strict;

BEGIN
   {
   plan tests => 10;
   chdir 't' if -d 't';
   use lib '../lib';
   use_ok ("Graph::Convert") or die($@);
   };

#############################################################################
# both Graph and Graph::Easy are automatically loaded:

my $g = Graph->new( multiedged => 1 );

is (ref($g), 'Graph');

my $edge = $g->add_edge_get_id( 'Bonn', 'Berlin' );

$g->set_edge_attribute_by_id( 'Bonn', 'Berlin', $edge, 'label', 'by train');

my $ge = Graph::Convert->as_graph_easy( $g );

is (scalar $ge->nodes(), 2, '2 nodes');
is (scalar $ge->edges(), 1, '1 edge');
is ($ge->is_simple_graph(), 1, 'simple graph (2 nodes, 1 edge)');

my @edges = $ge->edges();

my $e = $edges[0];
is (ref($e), 'Graph::Easy::Edge', '1 edge');

is ($e->attribute('label'), 'by train', 'attribute label survived');

#############################################################################
# class attributes as well as attributes on the graph itself

$ge = Graph::Easy->new();

$ge->add_edge('A','B');

$ge->set_attribute('color', 'red');

$g = Graph::Convert->as_graph( $ge );

is ($g->get_graph_attribute('graph_color'),'red', 'color was carried over');

my $ge_2 = Graph::Convert->as_graph_easy( $g );

is ($ge_2->get_attribute('graph','color'), 'red', 'color was carried back');
is ($ge_2->get_attribute('color'), 'red', 'color was carried back');

