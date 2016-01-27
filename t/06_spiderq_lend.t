#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use Test::More;

use SpiderQ qw( :flags :add :lend );
use String::Random qw( random_string );


plan('tests' => 14);

SKIP: {
    if ( not defined $ENV{'SPIDERQ_SERVER'} ) {
        skip('SPIDERQ_SERVER is not set', 14);
    }
    
    my $sq = SpiderQ->new('server' => $ENV{'SPIDERQ_SERVER'}, 'timeout' => $ENV{'SPIDERQ_TIMEOUT'});
    
    can_ok($sq, 'lend');
    
    my $key = random_string('00000000', [ 'a' .. 'z', '0' .. '9', '_' ]);
    my $value = 'value';
    my $lend_timeout = 1_000;
    
    $sq->remove($key);
    
    my ( $flag, $lend_key, $lent_key, $lent_value ) = $sq->lend($lend_timeout, $SQ_LEND_POLL);
    
    isnt($flag, undef, "Lend($lend_timeout, $SQ_LEND_POLL): success");
    is($flag, $SQ_QUEUE_EMPTY, "Lend($lend_timeout, $SQ_LEND_POLL) -> QueueEmpty()");
    is($lend_key, undef, 'lend key not defined');
    is($lent_key, undef, 'key not defined');
    is($lent_value, undef, 'value not defined');
    
    $sq->add($key, $value, $SQ_ADD_HEAD);
    
    ( $flag, $lend_key, $lent_key, $lent_value ) = $sq->lend($lend_timeout, $SQ_LEND_BLOCK);
    
    isnt($flag, undef, "Lend($lend_timeout, $SQ_LEND_BLOCK): success");
    is($flag, $SQ_LENT, "Lend($lend_timeout, $SQ_LEND_BLOCK) -> Lent()");
    
    isnt($lend_key, undef, 'lend key defined');
    cmp_ok($lend_key, '>=', 0, 'lend key >= 0');
    
    isnt($lent_key, undef, 'key defined');
    is($lent_key, $key, 'lent key equals key');
    
    isnt($lent_value, undef, 'value defined');
    is($lent_value, $value, 'lent value equals value');
    
    $sq->remove($key);
};

done_testing();


__END__