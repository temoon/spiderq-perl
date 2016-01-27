#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use ExtUtils::MakeMaker;


WriteMakefile(
    'NAME' => 'SpiderQ',
    'AUTHOR' => 'Tema Novikov <novikov.tema@gmail.com>',
    'VERSION_FROM' => 'lib/SpiderQ.pm',
    'LICENSE' => 'mit',
    
    'MIN_PERL_VERSION' => '5.008_008',
    
    'CONFIGURE_REQUIRES' => {
        'ExtUtils::MakeMaker' => '6.63_03',
    },
    
    'PREREQ_PM' => {
        'Carp' => 0,
        'Encode' => '2.0',
        'English' => 0,
        'Exporter' => 0,
        'Readonly' => 0,
        'ZMQ::LibZMQ3' => 0,
        'ZMQ::Constants' => 0,
    },
    
    'TEST_REQUIRES' => {
        'Test::More' => 0,
        'String::Random' => 0,
    },
);


__END__