   
package Emma::Sip;

use Moose;
use namespace::autoclean;

use IO::Socket::INET;
use Net::SIP;
use Net::SIP::Util 'create_socket_to';
use Net::SIP::Debug;

with 'Emma::Role::Params';

sub _prepare () {
    my $self = shift;

    Net::SIP::Debug->level($self->debug) if defined $self->debug;

    ###################################################
    # find local leg
    ###################################################
    my ($local_host,$local_port);
    if ( $self->leg ) {
    	($local_host,$local_port) = split( m/:/,$self->leg,2 );
    } elsif ( ! $self->proxy ) {
    	# if no proxy is given we need to find out
    	# about the leg using the IP given from FROM
        my $from = $self->from;
    	($local_host,$local_port) = $from =~m{\@([\w\-\.]+)(?::(\d+))?}
    		or die "cannot find SIP domain in '$from'";
    }
    
    my $leg;
    if ( $local_host ) {
    	my $addr = gethostbyname( $local_host )
    		|| die "cannot get IP from SIP domain '$local_host'";
    	$addr = inet_ntoa( $addr );
        
    	$leg = IO::Socket::INET->new(
    		Proto => 'udp',
    		LocalAddr => $addr,
    		LocalPort => $local_port || 5060,
    	);
    
    	# if no port given and port 5060 is already used try another one
    	if ( !$leg && !$local_port ) {
    		$leg = IO::Socket::INET->new(
    			Proto => 'udp',
    			LocalAddr => $addr,
    			LocalPort => 0
    		) || die "cannot create leg at $addr: $!";
    	}
    
    	$leg = Net::SIP::Leg->new( sock => $leg );
    }
    
    
    ###################################################
    # SIP code starts here
    ###################################################
    
    # create necessary legs
    # If I have an only outgoing proxy I could skip this step because constructor
    # can make leg to outgoing_proxy itself
    my @legs;
    push @legs,$self->leg if $self->leg;
    foreach my $addr ( $self->proxy,$self->registrar) {
    	$addr || next;
    	if ( ! grep { $_->can_deliver_to( $addr ) } @legs ) {
    		my $sock = create_socket_to($addr) || die "cannot create socket to $addr";
    		push @legs, Net::SIP::Leg->new( sock => $sock );
    	}
    }

    # create user agent
    my $ua = Net::SIP::Simple->new(
    	from => $self->from,
    	outgoing_proxy => $self->proxy,
    	legs => \@legs,
    	$self->username ? ( auth => [ $self->username,$self->password ] ):(),
    );
    
    # optional registration
    if ( $self->registrar && $self->registrar ne '-' ) {
    	$ua->register( registrar => $self->registrar );
    	die "registration failed: ".$ua->error if $ua->error
    }
   
    my @files; ### TODO
    my $ring_time = 30; ### TODO

    # invite peer, send first file
    my $peer_hangup; # did peer hang up?
    my $no_answer; # or didn't it even answer?
    my $rtp_done; # was sending file completed?
    my $call = $ua->invite( $self->to,
    	# echo back, use -1 instead of 0 for not echoing back
    	init_media => $ua->rtp( 'send_recv', $files[0] ),
    	cb_rtp_done => \$rtp_done,
    	recv_bye => \$peer_hangup,
    	cb_noanswer => \$no_answer,
    	ring_time => $ring_time,
    ) || die "invite failed: ".$ua->error;
    die "invite failed(call): ".$call->error if $call->error;
    
    DEBUG( "Call established (maybe), sending first file $files[0]" );
    $ua->loop( \$rtp_done,\$peer_hangup,\$no_answer );
    
    die "Ooops, no answer." if $no_answer;
    
    # mainloop until other party hangs up or we are done
    # send one file after the other using re-invites
    while ( ! $peer_hangup ) {
    
    	shift(@files); # done with file
    	@files || last;
    
    	# re-invite on current call for next file
    	DEBUG( "rtp_done=$rtp_done" );
    	my $rtp_done;
    	$call->reinvite(
    		init_media => $ua->rtp( 'send_recv', $files[0] ),
    		cb_rtp_done => \$rtp_done,
    		recv_bye => \$peer_hangup, # FIXME: do we need to repeat this?
    	);
    	DEBUG( "sending next file $files[0]" );
    	$ua->loop( \$rtp_done,\$peer_hangup );
    }
    
    unless ( $peer_hangup ) {
    	# no more files: hangup
    	my $stopvar;
    	$call->bye( cb_final => \$stopvar );
    	$ua->loop( \$stopvar );
    }

}

__PACKAGE__->meta->make_immutable;

1;

