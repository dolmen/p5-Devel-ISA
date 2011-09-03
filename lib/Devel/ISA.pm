package # hide package name from indexer
  DB;

# allow -d:ISA loading
sub DB {}

package Devel::ISA;

use strict;
use warnings;

our $VERSION = '1.00';

my @roots;

# Executes the END block only if loaded from the command-line
# with -d:ISA or -MDevel::ISA (in those cases the line number is 0)
our $do_END = ! (caller)[2];


sub import
{
    # Import functions only if imported from script/module
    # We could be imported from multiple places so we must not rely on !$do_END
    if ((caller)[2]) {
        splice @_, 1;
        our @EXPORT = ('ISA_tree');
	require Exporter;
        goto &Exporter::import;
    } else {
        # TODO: parse arguments for running END
    }
}

END {
    return unless $do_END;

    my $isa = ISA_tree('');

    # get all children that are not parents
    my %is_parent = map { $_ => 1 } map {@$_} values %$isa;

    # text output
    print as_text( $_ => $isa )
        for sort grep { !$is_parent{$_} } keys %$isa;
}

sub as_text {
    my ( $module, $isa, $level ) = @_;
    $level ||= 0;
    return join '', '  ' x $level, $module, "\n",
        map { as_text( $_, $isa, $level + 1 ) } @{ $isa->{$module} || [] };
}

sub as_yaml {
    my ($isa) = @_;
    return join '', "---\n", map {
        ( "$_:\n", map {"  - $_\n"} @{ $isa->{$_} } )
        } sort keys %$isa
}

sub ISA_tree {
    my ( $package, $isa ) = @_;
    $isa ||= {};
    my $prefix = $package eq 'main' || !$package ? '' : "$package\::";

    no strict 'refs';

    # update the data structure
    $isa->{$package} = [ @{"$package\::ISA"} ] if @{"$package\::ISA"};

    # recursively explore namespaces below this one
    ISA_tree( "$prefix$_", $isa ) for grep { !exists $isa->{$_} }
        grep { !/^\*?main/ }
        map { substr( $_, 0, -2 ) }
        grep /::$/,
        keys %{"$package\::"};

    return $isa;
}

1;

__END__

=head1 NAME

Devel::ISA - Show the class hierarchies loaded by your program

=head1 SYNOPSIS

    perl -d:ISA yourscript.pl

=head1 DESCRIPTION

=head1 AUTHOR

Philippe Bruhat (BooK), C<< <book at cpan.org> >>

=cut

