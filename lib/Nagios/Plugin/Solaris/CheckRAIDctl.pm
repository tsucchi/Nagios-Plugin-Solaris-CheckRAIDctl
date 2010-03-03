package Nagios::Plugin::Solaris::CheckRAIDctl;
use strict;
use warnings;
use Nagios::Plugin;

our $VERSION = "0.01";
use 5.008;

=head1 NAME

Nagios::Plugin::Solaris::CheckRAIDctl - Nagios plugin for checking raild status using raidctl

=head1 SYNOPSIS

  use strict;
  use warnings;
  use Nagios::Plugin::Solaris::CheckRAIDctl;
  my $c = Nagios::Plugin::Solaris::CheckRAIDctl->new();
  $c->run();


=head1 DESCRIPTION

Nagios plugin for checking raid status using raidctl.

=head1 RESTRICTION

It may work ONLY Sun Fire X2200M2 because I confirmed only this machine...

=head1 methods

=cut

=head2 new

create instance. specify raid volume with '--volume' option(required)

=cut

sub new {
    my $class = shift;
    my (%option) = @_;
    my $self = {
        np => Nagios::Plugin->new(
            shortname => 'raidctl',
            usage => "Usage: %s [ -v|--verbose ]  [-H <host>] [-t <timeout>] [--volume=<disk volume>]"
        ),
        raidctl  => $option{raidctl} || '/usr/sbin/raidctl',
    };
    bless $self, $class;

    $self->{np}->add_arg(
        spec => 'volume=s', 
        help => "--volume\n   volume_string(like c0t0d0)",
        required => 1,
    );
    $self->{np}->getopts;
    return $self;
}

=head2 run

start checking raid status

=cut

sub run {
    my $self = shift;
    my $status = $self->_raid_status;
    if ( $status eq 'OPTIMAL') {
        $self->{np}->nagios_exit(OK, "RAID STATUS IS $status");
    }
    else {
        $self->{np}->nagios_exit(CRITICAL, "RAID STATUS IS $status");
    }
}

# volume info
sub _volume {
    my $self = shift;
    return $self->{np}->opts->volume;
}

# RAID STATUS
sub _raid_status {
    my $self = shift;
    my $raidctl_result = $self->_exec_raidctl();
    for my $line ( split(/\n/, $raidctl_result) ) {
        my $volume = $self->_volume;
        next if ( $line !~ /^$volume/ );
        my $raid_status = (split(/\s+/, $line))[3];
        return $raid_status;
    }
    return "UNKNOWN";
}

sub _exec_raidctl {
    my $self = shift;
    my $raidctl = $self->{raidctl};
    $self->{np}->nagios_exit(UNKNOWN, 'raidctl is not found') if ( !defined $raidctl || !-x $raidctl );
    my $volume = $self->_volume;
    $self->{np}->nagios_exit(UNKNOWN, 'target disk volume is undefined') if ( !defined $volume );
    my $result = `$raidctl -l $volume`;
    return $result;
}

1;
__END__

=head1 AUTHOR

Takuya Tsuchida E<lt>tsucchi@cpan.orgE<gt>

=head1 SEE ALSO

check_raidctl: script bundled with this module

=head1 REPOSITORY

L<http://github.com/tsucchi/Nagios-Plugin-Solaris-CheckRAIDctl>


=head1 COPYRIGHT AND LICENSE

Copyright (c) 2010 Takuya Tsuchida

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
