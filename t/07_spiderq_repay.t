#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use Test::More;

use SpiderQ qw( :flags :add :lend :repay );
use String::Random qw( random_string );


plan('tests' => 9);

SKIP: {
    if ( not defined $ENV{'SPIDERQ_SERVER'} ) {
        skip('SPIDERQ_SERVER is not set', 9);
    }
    
    my $sq = SpiderQ->new('server' => $ENV{'SPIDERQ_SERVER'}, 'timeout' => $ENV{'SPIDERQ_TIMEOUT'});
    
    can_ok($sq, 'repay');
    
    my $key = random_string('00000000', [ 'a' .. 'z', '0' .. '9', '_' ]);
    my $value = 'value';
    my $new_value = 'new value';
    
    $sq->remove($key);
    
    my $flag = $sq->repay(0, $key, $value, $SQ_REPAY_FRONT);
    
    isnt($flag, undef, "Repay(0, '$key', '$value', $SQ_REPAY_FRONT): success");
    is($flag, $SQ_NOT_FOUND, "Repay(0, '$key', '$value', $SQ_REPAY_FRONT) -> NotFound()");
    
    $sq->add($key, $value, $SQ_ADD_HEAD);
    
    my ( undef, $lend_key, $lent_key, $lent_value ) = $sq->lend(1_000, $SQ_LEND_BLOCK);
    
    $flag = $sq->repay($lend_key, $lent_key, $new_value, $SQ_REPAY_REWARD);
    
    isnt($flag, undef, "Repay($lend_key, '$lent_key', '$new_value', $SQ_REPAY_REWARD): success");
    is($flag, $SQ_REPAID, "Repay($lend_key, '$lent_key', '$new_value', $SQ_REPAY_REWARD) -> Repaid()");
    
    ( undef, $lend_key, $lent_key, $lent_value ) = $sq->lend(1_000, $SQ_LEND_BLOCK);
    
    $flag = $sq->repay($lend_key, $lent_key, $new_value, $SQ_REPAY_PENALTY);
    
    isnt($flag, undef, "Repay($lend_key, '$lent_key', '$new_value', $SQ_REPAY_PENALTY): success");
    is($flag, $SQ_REPAID, "Repay($lend_key, '$lent_key', '$new_value', $SQ_REPAY_PENALTY) -> Repaid()");
    
    ( undef, $lend_key, $lent_key, $lent_value ) = $sq->lend(1_000, $SQ_LEND_BLOCK);
    
    $flag = $sq->repay($lend_key, $lent_key, $new_value, $SQ_REPAY_DROP);
    
    isnt($flag, undef, "Repay($lend_key, '$lent_key', '$new_value', $SQ_REPAY_DROP): success");
    is($flag, $SQ_REPAID, "Repay($lend_key, '$lent_key', '$new_value', $SQ_REPAY_DROP) -> Repaid()");
    
    $sq->remove($key);
};

done_testing();


__END__