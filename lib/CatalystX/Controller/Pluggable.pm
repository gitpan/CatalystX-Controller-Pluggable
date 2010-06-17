package CatalystX::Controller::Pluggable;
use Moose;
use Module::Pluggable::Object;
use Moose::Util;
extends 'Catalyst::Controller';
# ABSTRACT: Pluggable Roles for your controller
our $VERSION = '0.01';

has 'plugin_path' => ( 
   is => 'rw',
   default => sub { 
      my $class = ref shift;
      my ($base, $tail) = ($class =~ /^(.*)::Controller::(.*)/);
      $base . '::Plugins::' . $tail;
   }
);

sub BUILD {
   my( $self ) = @_;

   my $finder = Module::Pluggable::Object->new(
      require => 1,
      search_path => $self->plugin_path
   );
   if( $finder->plugins() ) { 
      Moose::Util::apply_all_roles( $self, $finder->plugins );
   }
   super( @_ );
}


1;

__END__

=head1 NAME

Catalyst::Controller::Pluggable

=head1 VERSION

version 0.01

=head1 SYNOPSIS

In your controller...

 BEGIN{ extends 'CatalystX::Controller::Pluggable' }

And write a plugin..

 package Some::Path::To::Plugins::Example;
 use Moose::Role;
 
 before 'view' => sub { 
   my( $self, $c ) = @_;
   $c->log->debug('About to call view..');
 };

 1;

=head1 DESCRIPTION

This just uses Module::Pluggabe::Object to apply some roles at runtime
to a Catalyst controller.  Nothing special.

Assuming an application name C<MyApp> and a controller C<TestController>,
plugins are searched for by default in C<MyApp::Plugins::TestController>.
This behaviour may be changed by setting the C<plugin_path> attribute
in your controller:

 has 'plugin_path' => ( 
   is => 'rw',
   default => 'Somewhere::Else::To::Search'
 );

The value is simply passed to L<Module::Pluggable::Object>'s C<search_path>
with no checking done.  

=head1 BUGS

Prolly.

=head1 AUTHOR

Dave Houston C<< dhouston@cpan.org >>

=head1 COPYRIGHT AND LICENSE

Copyright 2010, Dave Houston

This program is free software; you can redistribute and/or modify it
under the same terms as Perl itself.