############################################################################
# Convert between various graph formats.
#
# (c) by Tels 2006.
#############################################################################

package Graph::Convert;

use 5.008001;
use Graph::Easy;
use Graph;

$VERSION = '0.03';

use strict;

#############################################################################
# conversion

sub as_graph
  {
  # convert a Graph::Easy object to a Graph object
  my ($self,$in) = @_;

  Graph::Easy::Base->_croak(
    "as_graph needs a Graph::Easy object, but got '". ref($in). "'" )
   unless ref($in) && $in->isa('Graph::Easy');
 
  my $out = Graph->new( multiedged => 1); 

  # add the graph attributes
  my $att = $in->{att};

  for my $class (keys %$att)
    {
    my $c = $att->{$class};
    for my $attr (keys %$c)
      {
      $out->set_graph_attribute($class.'_'.$attr, $c->{$attr});
      }
    }

  # add all nodes
  for my $n ($in->nodes())
    {
    # the node name is unique, so we can use it as the "vertex id"
    $out->add_vertex($n->{name});
    my $attr = $n->raw_attributes();
    $out->set_vertex_attributes($n->{name}, $attr);
    }

  # add all edges
  for my $e ($in->edges())
    {
    # Adding an edge more than once will result in a new ID
    my $from = $e->{from}->{name}; my $to = $e->{to}->{name};
    my $id = $out->add_edge_get_id($from,$to);
    my $attr = $e->raw_attributes();
    $out->set_edge_attributes_by_id($from, $to, $id, $attr);
    }

  $out;
  }

sub as_graph_easy
  {
  # convert a Graph object to a Graph::Easy object
  my ($self,$in) = @_;
 
  Graph::Easy::Base->_croak(
    "as_graph_easy needs a Graph object, but got '". ref($in). "'" )
   unless ref($in) && $in->isa('Graph');
 
  my $out = Graph::Easy->new(); 

  # restore the graph attributes
  my $att = $in->get_graph_attributes();

  for my $key (keys %$att)
    {
    next unless $key =~ /^((graph|(node|edge|group))(\.\w+)?)_(.+)/;

    my $class = $1; my $name = $5;

    $out->set_attribute($1,$5, $att->{$key});
    }

  for my $n ($in->vertices())
    {
    my $node = $out->add_node($n);
    my $attr = $in->get_vertex_attributes($n);
    $node->set_attributes($attr);
    }
  for my $e ($in->edges())
    {
    # get all the IDs in case of the edge existing more than once:
    my @ids = $in->get_multiedge_ids($e->[0], $e->[1]);
    for my $id (@ids)
      {
      my $edge = $out->add_edge($e->[0],$e->[1]);
      my $attr = $in->get_edge_attributes_by_id($e->[0], $e->[1], $id);
      $edge->set_attributes($attr);
      }
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

=over 12

=item as_graph()

This routine always creates a multiedged graph, even if the input
Graph:Easy is a simple one - e.g. with never more than one edge
leading from node A to B.

=item as_graph_easy()

This routine expects multiedged graph.

=back

=head1 SEE ALSO

L<Graph>, L<Graph::Easy> and L<Graph::Easy::Manual>.

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
