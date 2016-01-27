# -*- coding: utf-8 -*-


package SpiderQ;


use 5.14.2;
use strict;
use warnings;
use utf8;
use base qw( Exporter );

use Carp;
use English qw( -no_match_vars );
use Readonly;

use Encode qw( encode decode is_utf8 );
use ZMQ::LibZMQ3;
use ZMQ::Constants qw( ZMQ_REQ ZMQ_LINGER ZMQ_POLLIN );


our @EXPORT_LEND = qw(
    $SQ_LEND_BLOCK
    $SQ_LEND_POLL
);

our @EXPORT_REPAY = qw(
    $SQ_REPAY_PENALTY
    $SQ_REPAY_REWARD
    $SQ_REPAY_FRONT
    $SQ_REPAY_DROP
);

our @EXPORT_ADD = qw(
    $SQ_ADD_HEAD
    $SQ_ADD_TAIL
);

our @EXPORT_OK = ( @EXPORT_LEND, @EXPORT_REPAY, @EXPORT_ADD );

our %EXPORT_TAGS = (
    'lend'  => \@EXPORT_LEND,
    'repay' => \@EXPORT_REPAY,
    'add'   => \@EXPORT_ADD,
);


Readonly::Scalar(my $ZMQ_POLL_TIMEOUT => 1_000);


Readonly::Scalar(my $SQ_COUNT     => 0x01);
Readonly::Scalar(my $SQ_ADD       => 0x02);
Readonly::Scalar(my $SQ_UPDATE    => 0x03);
Readonly::Scalar(my $SQ_LEND      => 0x04);
Readonly::Scalar(my $SQ_REPAY     => 0x05);
Readonly::Scalar(my $SQ_HEARTBEAT => 0x06);
Readonly::Scalar(my $SQ_STATS     => 0x07);
Readonly::Scalar(my $SQ_TERMINATE => 0x08);
Readonly::Scalar(my $SQ_LOOKUP    => 0x09);
Readonly::Scalar(my $SQ_FLUSH     => 0x0A);
Readonly::Scalar(my $SQ_PING      => 0x0B);
Readonly::Scalar(my $SQ_REMOVE    => 0x0C);

Readonly::Scalar(our $SQ_COUNTED         => 0x01);
Readonly::Scalar(our $SQ_ADDED           => 0x02);
Readonly::Scalar(our $SQ_KEPT            => 0x03);
Readonly::Scalar(our $SQ_UPDATED         => 0x04);
Readonly::Scalar(our $SQ_NOT_FOUND       => 0x05);
Readonly::Scalar(our $SQ_LENT            => 0x06);
Readonly::Scalar(our $SQ_REPAID          => 0x07);
Readonly::Scalar(our $SQ_HEARTBEATEN     => 0x08);
Readonly::Scalar(our $SQ_SKIPPED         => 0x09);
Readonly::Scalar(our $SQ_STATS_GOT       => 0x0A);
Readonly::Scalar(our $SQ_TERMINATED      => 0x0C);
Readonly::Scalar(our $SQ_VALUE_FOUND     => 0x0D);
Readonly::Scalar(our $SQ_VALUE_NOT_FOUND => 0x0E);
Readonly::Scalar(our $SQ_FLUSHED         => 0x0F);
Readonly::Scalar(our $SQ_QUEUE_EMPTY     => 0x10);
Readonly::Scalar(our $SQ_PONG            => 0x11);
Readonly::Scalar(our $SQ_REMOVED         => 0x12);
Readonly::Scalar(our $SQ_NOT_REMOVED     => 0x13);

Readonly::Scalar(our $SQ_LEND_BLOCK => 0x01);
Readonly::Scalar(our $SQ_LEND_POLL  => 0x02);

Readonly::Scalar(our $SQ_REPAY_PENALTY => 0x01);
Readonly::Scalar(our $SQ_REPAY_REWARD  => 0x02);
Readonly::Scalar(our $SQ_REPAY_FRONT   => 0x03);
Readonly::Scalar(our $SQ_REPAY_DROP    => 0x04);

Readonly::Scalar(our $SQ_ADD_HEAD => 0x01);
Readonly::Scalar(our $SQ_ADD_TAIL => 0x02);


sub new {
    
    my ( $class, %options ) = @_;
    
    my $zmq_context = zmq_ctx_new() or croak("$OS_ERROR");
    my $zmq_socket = zmq_socket($zmq_context, ZMQ_REQ) or croak("$OS_ERROR");
    
    zmq_connect($zmq_socket, $options{'server'});
    zmq_setsockopt($zmq_socket, ZMQ_LINGER, 0);
    
    my $object = {
        '_zmq_context' => $zmq_context,
        '_zmq_socket' => $zmq_socket,
        
        '_zmq_poll_timeout' => $options{'timeout'} // $ZMQ_POLL_TIMEOUT,
    };
    
    my $self = bless $object, $class;
    
    return $self;
    
}


sub DESTROY {
    
    my ( $self ) = @_;
    
    zmq_close($self->{'_zmq_socket'});
    zmq_ctx_destroy($self->{'_zmq_context'});
    
    return;
    
}


sub ping {
    
    my ( $self ) = @_;
    
    my $request = __make_int8($SQ_PING);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag ) = unpack 'C', $response;
    
    return $flag;
    
}


sub count {
    
    my ( $self ) = @_;
    
    my $request = __make_int8($SQ_COUNT);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag, $count ) = unpack 'CN', $response;
    
    return $flag, $count;
    
}


sub add {
    
    my ( $self, $key, $value, $mode ) = @_;
    
    my $request = __make_int8($SQ_ADD) . __make_string($key) . __make_string($value) . __make_int8($mode);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag ) = unpack 'C', $response;
    
    return $flag;
    
}


sub update {
    
    my ( $self, $key, $value ) = @_;
    
    my $request = __make_int8($SQ_UPDATE) . __make_string($key) . __make_string($value);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag ) = unpack 'C', $response;
    
    return $flag;
    
}


sub lookup {
    
    my ( $self, $key ) = @_;
    
    my $request = __make_int8($SQ_LOOKUP) . __make_string($key);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag, $value_length, $value ) = unpack 'CNa*', $response;
    
    if ( $flag == $SQ_VALUE_FOUND and length($value) eq $value_length ) {
        $value = decode('UTF-8', $value);
    } else {
        undef $value;
    }
    
    return $flag, $value;
    
}


sub remove {
    
    my ( $self, $key ) = @_;
    
    my $request = __make_int8($SQ_REMOVE) . __make_string($key);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag ) = unpack 'C', $response;
    
    return $flag;
    
}


sub lend {
    
    my ( $self, $timeout, $mode ) = @_;
    
    my $request = __make_int8($SQ_LEND) . __make_int64($timeout) . __make_int8($mode);
    my $response = $self->_zmq_send($request, -1);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag, $lend_key, $payload ) = unpack 'CQ>a*', $response;
    
    my $key = undef;
    my $value = undef;
    
    if ( $flag == $SQ_LENT ) {
        my ( $length ) = unpack 'N', $payload;
        
        $key = decode('UTF-8', substr $payload, 4, $length);
        $value = decode('UTF-8', substr $payload, 8 + $length);
    } else {
        undef $lend_key;
    }
    
    return $flag, $lend_key, $key, $value;
    
}


sub repay {
    
    my ( $self, $lend_key, $key, $value, $status ) = @_;
    
    my $request = __make_int8($SQ_REPAY) . __make_int64($lend_key) . __make_string($key) . __make_string($value) . __make_int8($status);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag ) = unpack 'C', $response;
    
    return $flag;
    
}


sub heartbeat {
    
    my ( $self, $lend_key, $key, $timeout ) = @_;
    
    my $request = __make_int8($SQ_HEARTBEAT) . __make_int64($lend_key) . __make_string($key) . __make_int64($timeout);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag ) = unpack 'C', $response;
    
    return $flag;
    
}


sub stats {
    
    my ( $self ) = @_;
    
    my $request = __make_int8($SQ_STATS);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag, $ping, $count, $add, $update, $lookup, $remove, $lend, $repay, $heartbeat, $stats ) = unpack 'CQ>Q>Q>Q>Q>Q>Q>Q>Q>Q>', $response;
    
    if ( $flag != $SQ_STATS_GOT ) {
        undef $ping;
        undef $count;
        undef $add;
        undef $update;
        undef $lookup;
        undef $remove;
        undef $lend;
        undef $repay;
        undef $heartbeat;
        undef $stats;
    }
    
    return $flag, $ping, $count, $add, $update, $lookup, $remove, $lend, $repay, $heartbeat, $stats;
    
}


sub flush {
    
    my ( $self ) = @_;
    
    my $request = __make_int8($SQ_FLUSH);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag ) = unpack 'C', $response;
    
    return $flag;
    
}


sub terminate {
    
    my ( $self ) = @_;
    
    my $request = __make_int8($SQ_TERMINATE);
    my $response = $self->_zmq_send($request);
    
    if ( not defined $response ) {
        return;
    }
    
    my ( $flag ) = unpack 'C', $response;
    
    return $flag;
    
}


sub _zmq_send {
    
    my ( $self, $buffer ) = @_;
    
    if ( zmq_send($self->{'_zmq_socket'}, $buffer, -1) == -1 ) {
        return;
    }
    
    my $response = zmq_msg_init();
    
    my $poll = {
        'socket' => $self->{'_zmq_socket'},
        'events' => ZMQ_POLLIN,
        
        'callback' => sub {
            if ( zmq_msg_recv($response, $self->{'_zmq_socket'}) == -1 ) {
                $response = undef;
            }
            
            return;
        },
    };
    
    my @poll = zmq_poll([ $poll ], $self->{'_zmq_poll_timeout'});
    
    if ( scalar @poll and $poll[0] and defined $response ) {
        return zmq_msg_data($response);
    }
    
    return;
    
}


sub __make_int8 {
    
    return pack 'C', shift;
    
}


sub __make_int64 {
    
    return pack 'Q>', shift;
    
}


sub __make_string {
    
    my ( $string ) = @_;
    
    if ( is_utf8($string) ) {
        $string = encode('UTF-8', $string);
    }
    
    return pack 'Na*', length $string, $string;
    
}


1;