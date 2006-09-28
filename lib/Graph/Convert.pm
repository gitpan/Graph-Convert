############################################################################
# Convert between various graph formats.
#
# (c) by Tels 2006.
#############################################################################

package Graph::Convert;

use 5.008001;
use Graph::Easy;
use Graph;

$VERSION = '0.01';

use strict;

#############################################################################
# conversion

sub as_graph
  {
  # convert a Graph::Easy object to a Graph object
  my ($self,$in) = @_;

  Graph::Easy::Base->_croak(
    "as_graph needs a Graph::Easy object, but got '", ref($in). "'" )
   unless ref($in) && $in->isa('Graph::Easy');
 
  my $out = Graph->new(); 

  for my $n ($in->nodes())
    {
    $out->add_vertex($n->{name});
    }
  for my $e ($in->edges())
    {
    $out->add_edge($e->{from}->{name},$e->{to}->{name});
    }

  $out;
  }

sub as_graph_easy
  {
  # convert a Graph object to a Graph::Easy object
  my ($self,$in) = @_;
 
  Graph::Easy::Base->_croak(
    "as_graph_easy needs a Graph object, but got '", ref($in). "'" )
   unless ref($in) && $in->isa('Graph');
 
  my $out = Graph::Easy->new(); 

  for my $n ($in->vertices())
    {
    $out->add_node($n);
    }
  for my $e ($in->edges())
    {
    $out->add_edge($e->[0],$e->[1]);
    }

  $out;
  }

1;
__END__

=head1 NAME

Graph::Convert - Convert between graph formats: Graph and Graph::Easy

=head1 SYNOPSIS

	use Graph::Convert;
	
	my $graph_easy = Graph::Easy->new();
	$graph_easy->add_edge ('Bonn', 'Berlin');

	# from "Graph::Easy" to "Graph"
	my $graph = Graph::Convert->as_graph ( $graph_easy );
	
	# and back to "Graph::Easy"
	my $ge = Graph::Convert->as_graph_easy ( $graph );

	print $ge->as_ascii( );

	# prints:

	# +------+     +--------+
	# | Bonn | --> | Berlin |
	# +------+     +--------+

=head1 DESCRIPTION

C<Graph::Convert> lets you convert graphs between some popular graph formats:

	Graph
	Graph::Easy

X<graph>
X<graph::easy>
X<conversion>
X<convert>

=head2 Input

=head2 Output

=head1 METHODS

C<Graph::Convert> supports the following methods:

=head2 as_graph()

        use Graph::Convert;

        my $graph_easy = Graph::Easy->new( );
        my $graph = Graph::Convert->as_graph( $graph_easy );

Converts the given L<Graph::Easy> object into a L<Graph> object.

=head2 as_graph_easy()

        use Graph::Convert;

        my $graph = Graph->new( );
        my $graph_easy = Graph::Convert->as_graph_easy( $graph_easy );

Converts the given L<Graph> object into a L<Graph::Easy> object.

=head1 CAVEATS

This module does only convert vertices and edges, it neglets any attributes
as well as subgraphs/groups.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the terms of the GPL version 2.

See the LICENSE file for a copy of the GPL.

X<gpl>
X<license>

=head1 AUTHOR

Copyright (C) 2006 by Tels L<http://bloodgate.com>

X<tels>

=cut
