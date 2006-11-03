############################################################################
# Convert between various graph formats.
#
# (c) by Tels 2006.
#############################################################################

package Graph::Convert;

use 5.008001;
use Graph::Easy;
use Graph;

$VERSION = '0.04';

use strict;

#############################################################################
# conversion

sub _add_basics
  {
  # Add the graph and class attributes from $in to $out
  # Add all the nodes
  # Add the groups as pseudo_attributes to the graph (so we can recover them)
  my ($self, $in, $out) = @_;

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

  $out;
  }

sub as_graph
  {
  # convert a Graph::Easy object to a Graph object
  my ($self,$in) = @_;

  $self->error(
    "as_graph needs a Graph::Easy object, but got '". ref($in). "'" )
   unless ref($in) && $in->isa('Graph::Easy');
  
  return $self->as_multiedged_graph($in) unless $in->is_simple_graph();

  my $out = Graph->new(); 

  $self->_add_basics($in,$out);

  # add all edges
  for my $e ($in->edges())
    {
    my $from = $e->{from}->{name}; my $to = $e->{to}->{name};
    my $edge = $out->add_edge($from,$to);
    my $attr = $e->raw_attributes();
    $out->set_edge_attributes($from, $to, $attr);
    }

  $out;
  }

sub as_multiedged_graph
  {
  my ($self,$in) = @_;

  $self->error(
    "as_multiedged_graph needs a Graph::Easy object, but got '". ref($in). "'" )
   unless ref($in) && $in->isa('Graph::Easy');
 
  my $out = Graph->new(multiedged => 1); 

  $self->_add_basics($in,$out);

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
 
  $self->error(
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

  if ($in->is_multiedged())
    {
    # for multiedged graphs:
    for my $e ($in->unique_edges())
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
    }
  else
    {
    # for simple graphs
    for my $e ($in->edges())
      {
      my $edge = $out->add_edge($e->[0],$e->[1]);
      my $attr = $in->get_edge_attributes($e->[0], $e->[1]);
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
	$graph_easy->add_edge ('Berlin', 'Berlin');

	# from "Graph::Easy" to "Graph"
	my $graph = Graph::Convert->as_graph ( $graph_easy );
	
	# and back to "Graph::Easy"
	my $ge = Graph::Convert->as_graph_easy ( $graph );

	print $ge->as_ascii( );

	# Outputs something like:

	#                +----+
	#                v    |
	# +------+     +--------+
	# | Bonn | --> | Berlin |
	# +------+     +--------+

=head1 DESCRIPTION

C<Graph::Convert> lets you convert graphs between the graph formats
from L<Graph> and L<Graph::Easy>.

It takes a graph object in either format, and converts it to the desired
output format. It handles simple graphs as well as multi-edged graphs,
and also carries the attributes over.

This enables you to use all the layout and formatting capabilities
of C<Graph::Easy> on C<Graph> objects, as well as using the extensive
graph algorithms and manipulations of C<Graph> on C<Graph::Easy> objects.

X<graph>
X<easy>
X<graph-easy>
X<conversion>
X<convert>

=head2 Graph vs. Graph::Easy

Both C<Graph> and C<Graph::Easy> represent graphs, e.g. vertices (or nodes)
connected by edges. These graphs can have (arbitrary) attributes attached
to the graph, nodes or edges.

Both formats can serialize the graph by creating a text-representation,
but unlike C<Graph::Easy>, C<Graph> is not able to create the graph back
from the string form.

There are, however, some slight differences between these two packages:

=over 12

=item Graph

C<Graph> has different representations for multi-edges and simple graphs,
making it somewhat complicated to switch between these two.

It does have an extensive set of algorithms to manipulate the graph, but no
layout capabilities.

=item Graph::Easy

C<Graph::Easy> uses the same representation for multi-edged and simple graphs,
but has only basic operations to manipulate the graph.

It has, however, a build-in layouter which can lay out the graph on a
grid, as well the ability to output graphviz code. This enables output
of ASCII, HTML, SVG and all the formats that graphviz supports, like PNG.

In addition, C<Graph::Easy> supports class attributes. By setting the
attribute for a class and putting objects (nodes/edges etc) into
the proper class, it is easier to manipulate attributes for many
objects at once.

=back

=head1 METHODS

C<Graph::Convert> supports the following methods:

=head2 as_graph()

        use Graph::Convert;

        my $graph_easy = Graph::Easy->new( );
        my $graph = Graph::Convert->as_graph( $graph_easy );

Converts the given L<Graph::Easy> object into a L<Graph> object.

This routine creates either a simple or a multiedged graph, depending
on whether the input L<Graph::Easy> object is a simple graph or not.

If you want to force the output to be a multiedged graph object, use
L<as_multiedged_graph>.

Forcing the output to be a simple graph when the input is multi-edged
is not supported, as that would require to drop arbitrary edges from
the input.

=head2 as_multiedged_graph()

        use Graph::Convert;

        my $graph_easy = Graph::Easy->new( );
        my $graph = Graph::Convert->as_multiedged_graph( $graph_easy );

Converts the given L<Graph::Easy> object into a multi-edged L<Graph>
object, even if the input graph is a simple graph (meaning there
is only one edge going from node A to node B).

=head2 as_graph_easy()

        use Graph::Convert;

        my $graph = Graph->new( );
        my $graph_easy = Graph::Convert->as_graph_easy( $graph_easy );

Converts the given L<Graph> object into a L<Graph::Easy> object.

This routine handles simple as well as multiedges graphs.

Multi-vertexed graphs are not supported e.g. each node must exist only once
in the input graph.

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
