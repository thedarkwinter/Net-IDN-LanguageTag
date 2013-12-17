#!/usr/bin/perl -w

use 5.010;
use strict;
use warnings;
use Test::More tests => 3;

BEGIN {
    use_ok('Class::Accessor');
    use_ok('Locale::Language');
    use_ok('Locale::Script');
}

exit 0;