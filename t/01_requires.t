#!/usr/bin/perl -w

use 5.010;
use strict;
use warnings;
use Test::More tests => 5;

BEGIN {
    use_ok('Class::Accessor');
    use_ok('Locale::Language');
    use_ok('Locale::Script');
    use_ok('Locale::Country');
    use_ok('Net::IDN::LanguageTag');
}

exit 0;