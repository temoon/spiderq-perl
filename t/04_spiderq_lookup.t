#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use Test::More;

use SpiderQ qw( :flags :add );
use String::Random qw( random_string );


plan('tests' => 8);

SKIP: {
    if ( not defined $ENV{'SPIDERQ_SERVER'} ) {
        skip('SPIDERQ_SERVER is not set', 8);
    }
    
    my $sq = SpiderQ->new('server' => $ENV{'SPIDERQ_SERVER'}, 'timeout' => $ENV{'SPIDERQ_TIMEOUT'});
    
    can_ok($sq, 'lookup');
    
    my $key = random_string('00000000', [ 'a' .. 'z', '0' .. '9', '_' ]);
    my $value = 'value';
    
    $sq->remove($key);
    
    my ( $flag, $found_value ) = $sq->lookup($key);
    
    isnt($flag, undef, "Lookup('$key'): success");
    is($flag, $SQ_VALUE_NOT_FOUND, "Lookup('$key') -> ValueNotFound()");
    
    is($found_value, undef, 'value not defined');
    
    $sq->add($key, $value, $SQ_ADD_TAIL);
    
    ( $flag, $found_value ) = $sq->lookup($key);
    
    isnt($flag, undef, "Lookup('$key'): success");
    is($flag, $SQ_VALUE_FOUND, "Lookup('$key') -> ValueFound()");
    
    isnt($found_value, undef, 'found value defined');
    is($found_value, $value, 'found value equals value');
    
    $sq->remove($key);
};

done_testing();


__END__